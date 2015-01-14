class ChangePriceToInitialPrice < ActiveRecord::Migration
  def change
    rename_column :projects, :price, :initial_price
  end
end
