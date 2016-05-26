class AddTitleToCommercialFilms < ActiveRecord::Migration
  def change
    add_column :commercial_films, :title, :string
  end
end
