class CreateCommercialFilmTagships < ActiveRecord::Migration
  def change
    create_table :commercial_film_tagships do |t|
      t.integer :commercial_film_id, :tag_id
    end
  end
end
