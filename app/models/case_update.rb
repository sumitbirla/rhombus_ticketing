# == Schema Information
#
# Table name: crm_case_updates
#
#  id           :integer          not null, primary key
#  new_assignee :integer
#  new_priority :string(32)
#  new_state    :string(32)       default("")
#  private_note :text(65535)
#  raw_data     :text(4294967295)
#  received_at  :datetime         not null
#  received_via :string(255)
#  response     :text(65535)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  case_id      :integer
#  new_queue_id :integer
#  user_id      :integer
#
# Indexes
#
#  index_case_updates_on_case_id  (case_id)
#

class CaseUpdate < ActiveRecord::Base
  self.table_name = "crm_case_updates"

  attr_accessor :sms_source
  belongs_to :case
  belongs_to :user
  belongs_to :pbx_sms
  belongs_to :pbx_db_cdr
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many_attached :files
  validate :has_content?

  def has_content?
    if response.blank? &&
        private_note.blank? &&
        new_state.blank? &&
        new_priority.blank? &&
        new_queue_id.blank? &&
        new_assignee.nil? &&
        pbx_db_cdr_id.nil? &&
        pbx_sms_id.nil? &&
        files.length == 0
      errors.add(:base, "No update was specified.")
    end
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
