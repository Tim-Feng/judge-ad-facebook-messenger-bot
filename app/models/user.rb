class User < ActiveRecord::Base
  validates :facebook_user_id, uniqueness: true
  serialize :searched_tag_and_count
end