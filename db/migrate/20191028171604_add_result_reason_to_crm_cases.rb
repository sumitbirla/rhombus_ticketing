class AddResultReasonToCrmCases < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_cases, :result_reason, :string, after: :result
  end
end
