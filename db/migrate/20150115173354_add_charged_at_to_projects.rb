class AddChargedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :charged_at, :datetime
  end
end
