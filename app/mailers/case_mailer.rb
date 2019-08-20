class CaseMailer < ApplicationMailer
  
  def response(case_update)
    headers["X-Rhombus-Case-ID"] = case_update.case.id
    
    body = case_update.response + "\n\n"
    body += case_update.case.case_queue.reply_signature + "\n"
    body += "[case:::#{case_update.case.id}:::]\n\n"
		
		# Attachments if any
		case_update.files.each { |f| attachments[f.filename.to_s] = f.download }
    
    mail(from: "#{case_update.case.case_queue.reply_name} <#{case_update.case.case_queue.reply_email}>",
         to: case_update.case.email.presence || case_update.case.customer.email,
         subject: "RE: #{case_update.case.subject}",
         body: body)
  end
  
  def assigned(c)
    @case = c
    headers["X-Rhombus-Case-ID"] = @case.id
    
    mail(from: "#{@case.case_queue.reply_name} <#{@case.case_queue.reply_email}>",
         to: User.find(@case.assigned_to).email,
         subject: "Case ##{@case.id} has been assigned to you" )
  end
  
  def updated(case_update)
    @case_update = case_update
    headers["X-Rhombus-Case-ID"] = case_update.case.id
  
    mail(from: "#{case_update.case.case_queue.reply_name} <#{case_update.case.case_queue.reply_email}>",
         to: User.find(case_update.case.assigned_to).email,
         subject: "Case ##{case_update.case.id} has an update" )
  end
  
end
