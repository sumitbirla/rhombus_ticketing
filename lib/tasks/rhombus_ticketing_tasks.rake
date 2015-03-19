# desc "Explaining what the task does"
# task :rhombus_ticketing do
#   # Task goes here
# end

require 'mail'
require 'net/pop'

namespace :rhombus_ticketing do
  
  desc "TODO"
  task process_inbox: :environment do
    
    CaseQueue.where(pop3_enabled: true).each do |q|
          
      Net::POP3.start(q.pop3_host, q.pop3_port, q.pop3_login, q.pop3_password) do |pop|

        pop.each_mail do |mail|
          msg = Mail.new(mail.pop)
          
          puts msg.date.to_s + ": " + msg.from.to_s + " => " + msg.to.to_s + " => " + msg.attachments.length.to_s
        
          unless msg.multipart?
            desc = msg.body.decoded
          else     
            desc = msg.text_part.decoded
          end
               
          m = /Case :::\d{5}:::/.match(desc) 
          puts m.inspect
                
          if m && m.length > 0
            case_id = m[0].gsub("Case ", "").gsub(":::", "").to_i
            c = CaseUpdate.new(case_id: case_id,
                               received_at: msg.date,
                               attachments: msg.attachments.map { |x| x.filename }.join("|"),
                               raw_data: msg.to_s,
                               response: desc )
            # send email
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
            # send email
          end
                      
          user = User.find_by(email: msg.sender)   
          c.user_id = user.id unless user.nil?
          
          if c.save
            mail.delete
          else
            puts c.errors.inspect
          end
          
        end

      end
    
    end
  end
  
end
