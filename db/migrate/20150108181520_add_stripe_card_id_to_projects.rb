class AddStripeCardIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :stripe_card_id, :string
  end
end
