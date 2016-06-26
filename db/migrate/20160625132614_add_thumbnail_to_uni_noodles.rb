class AddThumbnailToUniNoodles < ActiveRecord::Migration
  def change
    add_column :uni_noodles, :thumbnail_url, :text
  end
end
