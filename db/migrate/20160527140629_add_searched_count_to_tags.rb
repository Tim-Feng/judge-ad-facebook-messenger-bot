class AddSearchedCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :searched_count, :integer
  end
end
