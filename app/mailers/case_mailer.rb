class CaseMailer < ApplicationMailer
  
  def response(case_update)
    headers["X-Rhombus-Case-ID"] = case_update.case.id
    
    body = case_update.response + "\n\n"
    body += case_update.case.case_queue.reply_signature + "\n"
    body += "[case:::#{case_update.case.id}:::]"
    
    options = {
        address: Cache.setting(Rails.configuration.domain_id, :system, 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    mail(from: "#{case_update.case.case_queue.reply_name} <#{case_update.case.case_queue.reply_email}>",
         to: case_update.case.email,
         subject: "RE: #{case_update.case.subject}",
         body: body,
         delivery_method_options: options
         )
  end
  
  def assigned(c)
    @case = c
    headers["X-Rhombus-Case-ID"] = @case.id
    
    options = {
        address: Cache.setting(Rails.configuration.domain_id, :system, 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    mail(from: "#{@case.case_queue.reply_name} <#{@case.case_queue.reply_email}>",
         to: User.find(@case.assigned_to).email,
         subject: "Case ##{@case.id} has been assigned to you",
         delivery_method_options: options
         )
  end
  
  def updated(c)
    @case = c
    headers["X-Rhombus-Case-ID"] = @case.id
  
    options = {
        address: Cache.setting(Rails.configuration.domain_id, :system, 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    mail(from: "#{@case.case_queue.reply_name} <#{@case.case_queue.reply_email}>",
         to: User.find(@case.assigned_to).email,
         subject: "Case ##{@case.id} has an update",
         delivery_method_options: options
         )
  end
  
end
