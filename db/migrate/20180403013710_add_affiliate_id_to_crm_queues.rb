class AddAffiliateIdToCrmQueues < ActiveRecord::Migration
  def change
    add_column :crm_queues, :affiliate_id, :integer
  end
end
