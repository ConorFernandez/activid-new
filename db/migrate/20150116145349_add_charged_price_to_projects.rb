class AddChargedPriceToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :charged_price, :integer
  end
end
