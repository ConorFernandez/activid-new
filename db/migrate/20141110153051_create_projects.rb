class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name, :category, :desired_length, :uuid
      t.text :instructions
      t.boolean :allow_to_be_featured, default: true

      t.timestamps
    end

    add_index :projects, :uuid
  end
end
