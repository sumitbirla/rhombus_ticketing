require 'mail'

namespace :rhombus do
  
  desc "TODO"
  task process_ticket_inbox: :environment do
  	Mail.defaults do
      retriever_method :pop3, { :address    => "pinto.tampahost.net",
                                :port       => 995,
                                :user_name  => 'crm',
                                :password   => 'crm321user',
                                :enable_ssl => true }
  	end

    Mail.all.each do |mail|
      puts mail.date.to_s + ": " + mail.from.to_s + " => " + mail.to.to_s
      puts mail.parts.map { |p| p.content_type }.to_s
      puts mail.attachments.map { |a| a.filename }.to_s
    end
  end
  
end
