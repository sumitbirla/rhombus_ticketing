class AddOtherEmailToCrmCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_customers, :other_email, :string, after: :email
    add_column :crm_cases, :last_inbound_at, :datetime, after: :received_at
  end
end
