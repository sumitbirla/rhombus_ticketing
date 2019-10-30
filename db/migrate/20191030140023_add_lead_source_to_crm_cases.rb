class AddLeadSourceToCrmCases < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_cases, :lead_source, :string, after: :received_via
  end
end
