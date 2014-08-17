# == Schema Information
#
# Table name: case_updates
#
#  id           :integer          not null, primary key
#  case_id      :integer
#  user_id      :integer          not null
#  response     :text             not null
#  data         :binary
#  private_note :text
#  state_update :boolean          not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CaseUpdate < ActiveRecord::Base
  self.table_name = "crm_case_updates"
  belongs_to :case
end
