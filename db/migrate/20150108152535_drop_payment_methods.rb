class DropPaymentMethods < ActiveRecord::Migration
  def up
    remove_column :projects, :payment_method_id
    drop_table :payment_methods
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
