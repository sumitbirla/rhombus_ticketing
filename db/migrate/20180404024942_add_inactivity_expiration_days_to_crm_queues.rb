class AddInactivityExpirationDaysToCrmQueues < ActiveRecord::Migration
  def change
    add_column :crm_queues, :inactivity_expiration_days, :integer, null: false, default: 10
	remove_column :crm_queues, :notify_email
  end
end
