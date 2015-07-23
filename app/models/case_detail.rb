# == Schema Information
#
# Table name: crm_case_details
#
#  id         :integer          not null, primary key
#  case_id    :integer          not null
#  sort       :integer          not null
#  key        :string(255)      not null
#  value      :text(65535)      not null
#  created_at :datetime
#  updated_at :datetime
#

class CaseDetail < ActiveRecord::Base
  self.table_name = "crm_case_details"
  belongs_to :case
end
