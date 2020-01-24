class AddExternalIdToCrmCases < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_cases, :external_id, :string, after: :user_id
  end
end
