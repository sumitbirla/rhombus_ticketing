# == Schema Information
#
# Table name: case_queues
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  notify_email       :string(255)
#  initial_assignment :integer
#  reply_name         :string(255)      not null
#  reply_email        :string(255)      not null
#  reply_signature    :text
#  web_instruction    :text
#  web_confirmation   :text
#  pop3_enabled       :boolean          not null
#  pop3_login         :string(255)
#  pop3_password      :string(255)
#  pop3_use_ssl       :boolean
#  pop3_error         :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  pop3_host          :string(255)
#

class CaseQueue < ActiveRecord::Base
  self.table_name = "crm_queues"
  has_many :cases
  belongs_to :assigned, class_name: 'User', foreign_key: 'initial_assignment'
  validates_presence_of :name, :reply_name, :reply_email

  def to_s
    name
  end
end
