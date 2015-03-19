class ChangeColumnsForCrmCases < ActiveRecord::Migration
  def change
	change_column :crm_cases, :attachments, :string
	rename_column :crm_case_updates, :data, :raw_data
	add_column :crm_case_updates, :attachments, :string
	add_column :crm_case_updates, :received_at, :datetime, null: false
  end
end
