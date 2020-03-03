class AddTypeToCrmCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :crm_customers, :type, :string, after: :name
  end
end
