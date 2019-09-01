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
	
	before_save :set_last_inbound
  
  belongs_to :case_queue
  belongs_to :user
  belongs_to :customer
  belongs_to :assignee, class_name: "User", foreign_key: "assigned_to"
	
  has_many :extra_properties, -> { order "sort, name" }, as: :extra_property
  has_many :updates, class_name: 'CaseUpdate', dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  
	accepts_nested_attributes_for :extra_properties, allow_destroy: true
  accepts_nested_attributes_for :updates, allow_destroy: true
	
  validates_presence_of :case_queue_id, :subject, :priority, :status, :received_via
  # validate :phone_or_email
  
  def self.valid_states
    ['new', 'open', 'closed']
  end
  
  def self.valid_priorities
    ['normal', 'high', 'urgent']
  end
	
  def get_property(name)
    a = extra_properties.find { |x| x.name == name }
    a.nil? ? "" : a.value
  end
  
  def set_property(name, value)
    a = extra_properties.find { |x| x.name == name }
    if [true, false].include? value
      value = (value ? "Yes" : "No")
    end
    
    if a.nil?
      self.extra_properties.build(name: name, value: value) unless value.blank?
    else
      if value.blank?
        a.destroy
      else
        a.update(value: value)
      end
    end
  end
  
  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end

  private
	
		def set_last_inbound
			if last_inbound_at.nil?
				self.last_inbound_at = DateTime.now
			end
		end

    #def phone_or_email
    #  if phone.blank? && email.blank?
    #    errors.add(:base, "Either an email address or phone number must be provided.")
    #  end
    #end
end
