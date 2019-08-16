class AddBlockedEmailsToCrmQueues < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_queues, :blocked_emails, :text
  end
end
