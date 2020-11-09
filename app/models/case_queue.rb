# == Schema Information
#
# Table name: crm_queues
#
#  id                         :integer          not null, primary key
#  affiliate_id               :integer
#  name                       :string(255)      not null
#  initial_assignment         :integer
#  reply_name                 :string(255)      not null
#  reply_email                :string(255)      not null
#  reply_signature            :text(65535)
#  web_instruction            :text(65535)
#  web_confirmation           :text(65535)
#  pop3_enabled               :boolean          not null
#  pop3_host                  :string(255)
#  pop3_port                  :integer          default(110), not null
#  pop3_login                 :string(255)
#  pop3_password              :string(255)
#  pop3_use_ssl               :boolean
#  pop3_error                 :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  inactivity_expiration_days :integer          default(10), not null
#

class CaseQueue < ActiveRecord::Base
  include Exportable

  self.table_name = "crm_queues"
  has_many :cases, dependent: :destroy
  belongs_to :affiliate
  belongs_to :assigned, class_name: 'User', foreign_key: 'initial_assignment'
  validates_presence_of :name, :reply_name, :reply_email
  validates_uniqueness_of :name, scope: :affiliate_id

  def to_s
    name
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
