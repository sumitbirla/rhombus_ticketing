require 'net/pop'


class TicketImportJob < ActiveJob::Base
  queue_as :default
  
  # reschedule job
  after_perform do |job|
    self.class.set(wait: 300).perform_later
  end
  
  
  # Do the work
  def perform(*args)  
    @logger = Logger.new(Rails.root.join("log", "crm.log"))
      
    CaseQueue.where(pop3_enabled: true).each do |q|
      
      Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if q.pop3_use_ssl
    
      Net::POP3.start(q.pop3_host, q.pop3_port, q.pop3_login, q.pop3_password) do |pop|
        pop.each_mail { |mail| process_message(q, mail) } 
      end  
    
    end  # each queue
  end
  
  
  # Parse single email message and put in database
  def process_message(q, mail)
    msg = Mail.new(mail.pop)
    @logger.debug msg.from.to_s + " => " + msg.to.to_s + "[#{msg.subject}]"
    
    unless msg.multipart?
      desc = msg.body.decoded
    else     
      desc = msg.text_part.decoded
    end
         
    m = /case:::\d{5}:::/.match(desc) 
       
    if m && m.length > 0
      case_id = m[0].gsub("case", "").gsub(":::", "").to_i
      c = CaseUpdate.new(case_id: case_id,
                         received_at: msg.date,
                         attachments: msg.attachments.map { |x| x.filename }.join("|"),
                         raw_data: msg.to_s,
                         response: desc )
    else
      c = Case.new( case_queue_id: q.id,
                  received_at: msg.date,
                  priority: :normal,
                  status: :new,
                  assigned_to: q.initial_assignment,
                  attachments: msg.attachments.map { |x| x.filename }.join("|"),
                  name: msg[:from].display_names.first || msg.from[0],
                  email: msg.from[0],
                  subject: msg.subject,
                  description: desc,
                  received_via: :email,
                  raw_data: msg.to_s )
    end
                
    user = User.find_by(email: msg.sender)   
    c.user_id = user.id unless user.nil?
    
    if c.save
      mail.delete

      if c.class.name == "CaseUpdate" 
        @logger.info "Case ##{c.case.id} received an update"
        CaseMailer.updated(c).deliver_later
      else
        @logger.info "Case ##{c.id} created"
        CaseMailer.assigned(c).deliver_later
      end
    end
    
  end
  
end
