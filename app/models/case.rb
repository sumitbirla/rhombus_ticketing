# == Schema Information
#
# Table name: crm_cases
#
#  id            :integer          not null, primary key
#  case_queue_id :integer          not null
#  received_at   :datetime         not null
#  priority      :string(255)      not null
#  status        :string(255)      not null
#  assigned_to   :integer
#  attachments   :string(255)
#  user_id       :integer
#  name          :string(255)      not null
#  email         :string(255)
#  phone         :string(255)
#  subject       :string(255)      not null
#  description   :text(65535)
#  received_via  :string(255)      not null
#  raw_data      :text(4294967295)
#  created_at    :datetime
#  updated_at    :datetime
#

class Case < ActiveRecord::Base
  include Exportable
  
  self.table_name = "crm_cases"
  
  belongs_to :case_queue
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: "assigned_to"
  
  has_many :extra_properties, -> { order "sort, name" }, as: :extra_property
  has_many :updates, class_name: 'CaseUpdate', dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  
  validates_presence_of :case_queue_id, :name, :subject, :priority, :status, :received_via
  validate :phone_or_email
  
  def self.valid_states
    ['new', 'open', 'closed']
  end
  
  def self.valid_priorities
    ['normal', 'high', 'urgent']
  end
  
  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end

  private

    def phone_or_email
      if phone.blank? && email.blank?
        errors.add(:base, "Either an email address or phone number must be provided.")
      end
    end
end
