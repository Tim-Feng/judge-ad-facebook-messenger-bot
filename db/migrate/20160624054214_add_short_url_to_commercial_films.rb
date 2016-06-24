class AddShortUrlToCommercialFilms < ActiveRecord::Migration
  def change
    add_column :commercial_films, :short_url, :text
  end
end
