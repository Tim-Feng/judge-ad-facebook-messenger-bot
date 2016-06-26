class CreateUniNoodles < ActiveRecord::Migration
  def change
    create_table :uni_noodles do |t|
      t.text :video_url, :video_short_url, :ost_url, :ost_short_url, :recipe_url, :recipe_short_url
      t.string :title, :ost_title
      t.timestamps
    end
  end
end
