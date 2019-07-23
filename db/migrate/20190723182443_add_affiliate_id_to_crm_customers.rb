class AddAffiliateIdToCrmCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_customers, :affiliate_id, :integer, after: :id
  end
end
