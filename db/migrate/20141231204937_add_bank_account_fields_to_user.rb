class AddBankAccountFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :stripe_recipient_id, :string
    add_column :users, :bank_account_last_four, :string
  end
end
