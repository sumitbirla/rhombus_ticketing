class TicketMailer < ApplicationMailer
  
  default from: "#{Cache.setting('System', 'From Email Name ')} <#{Cache.setting('System', 'From Email Address')}>"

  def new_ticket(case)
    @case = case
    @website_url  = Cache.setting('System', 'Website URL')
    @website_name = Cache.setting('System', 'Website Name')
  
    options = {
        address: Cache.setting('System', 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    mail(to: order.notify_email,
         subject: "New ticket ##{case.id} created",
         delivery_method_options: options)
         
   end
  

  def updated_ticket(case_update)
    @shipment = shipment
    @website_url  = Cache.setting('System', 'Website URL')
    @website_name = Cache.setting('System', 'Website Name')
    bcc = Cache.setting('eCommerce', 'Order Copy Recipient')

    options = {
        address: Cache.setting('System', 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    mail(to: shipment.order.notify_email,
         bcc: bcc,
         subject: "Order ##{@shipment.order.id} has shipped",
         delivery_method_options: options)
  end
  
end
