class RemoveAttachmentsFromCrmCases < ActiveRecord::Migration[5.2]
  def change
    remove_column :crm_cases, :attachments, :string
    remove_column :crm_case_updates, :attachments, :string
  end
end
