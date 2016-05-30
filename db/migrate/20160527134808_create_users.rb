class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :facebook_user_id
      t.text :searched_tag_and_count
    end
  end
end
