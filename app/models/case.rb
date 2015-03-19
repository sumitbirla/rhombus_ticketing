# == Schema Information
#
# Table name: cases
#
#  id            :integer          not null, primary key
#  case_queue_id :integer          not null
#  priority      :string(255)      not null
#  status        :string(255)      not null
#  assigned_to   :integer
#  user_id       :integer
#  name          :string(255)      not null
#  email         :string(255)
#  phone         :string(255)
#  subject       :string(255)      not null
#  description   :text
#  received_via  :string(255)      not null
#  form_data     :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Case < ActiveRecord::Base
  self.table_name = "crm_cases"
  
  scope :open, -> { where(status: 'open') }
  
  belongs_to :case_queue
  belongs_to :user
  has_many :details, class_name: 'CaseDetail'
  has_many :updates, class_name: 'CaseUpdate', dependent: :destroy
  belongs_to :assignee, class_name: "User", foreign_key: "assigned_to"

  validates_presence_of :case_queue_id, :name, :subject, :priority, :status, :received_via
  validate :phone_or_email
  
  def self.valid_states
    ['new', 'open', 'closed']
  end
  
  def self.valid_priorities
    ['normal', 'high', 'urgent']
  end

  private

    def phone_or_email
      if phone.blank? && email.blank?
        errors.add(:base, "Either an email address or phone number must be provided.")
      end
    end
end
