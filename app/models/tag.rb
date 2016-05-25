class Tag < ActiveRecord::Base
  has_many :commercial_film_tagships, dependent: :destroy
  has_many :commercial_films, through: :commercial_film_tagships
end