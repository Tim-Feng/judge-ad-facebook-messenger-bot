class CreateCommercialFilms < ActiveRecord::Migration
  def change
    create_table :commercial_films do |t|
      t.text :video_url, :thumbnail_url
      t.timestamps
    end
  end
end
