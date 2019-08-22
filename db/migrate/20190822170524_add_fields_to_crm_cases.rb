class AddFieldsToCrmCases < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_cases, :request_date, :date
    add_column :crm_cases, :follow_up_date, :date
    add_column :crm_cases, :result, :string
  end
end
