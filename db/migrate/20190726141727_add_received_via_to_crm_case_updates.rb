class AddReceivedViaToCrmCaseUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_case_updates, :received_via, :string, after: :received_at
  end
end
