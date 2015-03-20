# desc "Explaining what the task does"
# task :rhombus_ticketing do
#   # Task goes here
# end

require 'mail'
require 'net/pop'

namespace :rhombus_ticketing do
  
  desc "TODO"
  task process_inbox: :environment do
  
    logger = Logger.new("/var/log/crm.log")
    
    CaseQueue.where(pop3_enabled: true).each do |q|
          
      Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if q.pop3_use_ssl
      Net::POP3.start(q.pop3_host, q.pop3_port, q.pop3_login, q.pop3_password) do |pop|

        pop.each_mail do |mail|
          msg = Mail.new(mail.pop)
          
          logger.debug msg.from.to_s + " => " + msg.to.to_s + "[#{msg.subject}]"
        
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
            
            # send notofication email
            begin
              if c.class.name == "CaseUpdate" 
                logger.info "Case ##{c.case.id} received an update"
                CaseMailer.updated(c).deliver
              else
                logger.info "Case ##{c.case.id} created"
                CaseMailer.assigned(c).deliver
              end
            rescue => e
              logger.error e
            end
          
          end
          
        end

      end
    
    end
  end
  
end
