class SetDefaultValuseToSearchedCountOfTags < ActiveRecord::Migration
  def change
    change_column :tags, :searched_count, :integer, default: 0
  end
end
