# == Schema Information
#
# Table name: crm_cases
#
#  id              :integer          not null, primary key
#  assigned_to     :integer
#  description     :text(65535)
#  email           :string(255)
#  follow_up_date  :date
#  last_inbound_at :datetime
#  lead_source     :string(255)
#  name            :string(255)      not null
#  phone           :string(255)
#  priority        :string(255)      not null
#  raw_data        :text(4294967295)
#  received_at     :datetime         not null
#  received_via    :string(255)      not null
#  request_date    :date
#  result          :string(255)
#  result_reason   :string(255)
#  status          :string(255)      not null
#  subject         :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  case_queue_id   :integer          not null
#  customer_id     :integer
#  external_id     :string(255)
#  user_id         :integer
#
# Indexes
#
#  index_cases_on_case_queue_id  (case_queue_id)
#

class Case < ActiveRecord::Base
  include Exportable
  self.table_name = "crm_cases"

  before_save :set_last_inbound
  belongs_to :case_queue
  belongs_to :user
  belongs_to :customer
  belongs_to :assignee, class_name: "User", foreign_key: "assigned_to"
  belongs_to :auto_followup_notification_delivery_method, class_name: "NotificationDeliveryMethod"
  has_many :extra_properties, -> { order "sort, name" }, as: :extra_property
  has_many :updates,  -> { order "created_at" }, class_name: 'CaseUpdate', dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :extra_properties, allow_destroy: true
  accepts_nested_attributes_for :updates, allow_destroy: true

  validates_presence_of :case_queue_id, :priority, :status, :received_via
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

  def self.to_csv(list)

    CSV.generate do |csv|
      csv << ["ID", "Queue", "Received", "Received Via", "Status", "Priority", "Assigned To", "Customer Name", "Customer Mobile", "Customer Other Phone", "Customer Email", "Customer Other Email", "Notes", "Request Date", "Follow Up Date", "Result", "Last Inbound"]
      list.each do |x|
        csv << [x.id,
                x.case_queue.to_s,
                x.received_at,
                x.received_via,
                x.status,
                x.priority,
                x.assignee.to_s,
                x.customer.name,
                x.customer.mobile_phone,
                x.customer.other_phone,
                x.customer.email,
                x.customer.other_email,
                x.description,
                x.request_date,
                x.follow_up_date,
                x.result,
                x.last_inbound_at
        ]
      end
    end

  end

  def web_submission_valid?
    errors.add(:name, "Please enter your name.") if name.blank?
    errors.add(:base, "Either an email address or phone number must be provided.") if phone.blank? && email.blank?
    errors.add(:message, "Please type in your message to us.") if description.blank?
    return errors.count == 0
  end

  def has_flag?(f)
    flags && flags.split(";").include?(f)
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
