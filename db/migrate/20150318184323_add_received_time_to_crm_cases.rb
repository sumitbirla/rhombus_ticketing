class AddReceivedTimeToCrmCases < ActiveRecord::Migration
  def change
    add_column :crm_cases, :received_at, :datetime, after: :case_queue_id, null: false
  end
end
