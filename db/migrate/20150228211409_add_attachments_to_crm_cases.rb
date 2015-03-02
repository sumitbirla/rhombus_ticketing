class AddAttachmentsToCrmCases < ActiveRecord::Migration
  def change
    add_column :crm_cases, :attachments, :integer, after: :assigned_to, null: false, default: 0
	rename_column :crm_cases, :form_data, :raw_data
  end
end
