class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :user_id, :payment_method_id
      t.string :uuid
      t.string :name, :category, :desired_length, :turnaround
      t.text :instructions
      t.boolean :allow_to_be_featured, default: true
      t.boolean :watermark, default: true

      t.timestamps
    end

    add_index :projects, :uuid
  end
end
