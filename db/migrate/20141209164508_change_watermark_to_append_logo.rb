class ChangeWatermarkToAppendLogo < ActiveRecord::Migration
  def change
    rename_column :projects, :watermark, :append_logo
  end
end
