class AddNewQueueIdToCrmCaseUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_case_updates, :new_queue_id, :integer, before: :created_at
  end
end
