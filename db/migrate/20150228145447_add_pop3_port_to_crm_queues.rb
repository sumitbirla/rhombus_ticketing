class AddPop3PortToCrmQueues < ActiveRecord::Migration
  def change
    add_column :crm_queues, :pop3_port, :integer, after: :pop3_host, null: false, default: 110
  end
end
