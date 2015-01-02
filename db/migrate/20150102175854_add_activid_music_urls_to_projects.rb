class AddActividMusicUrlsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :activid_music_urls, :text
  end
end
