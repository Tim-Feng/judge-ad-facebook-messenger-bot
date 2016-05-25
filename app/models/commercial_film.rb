class CommercialFilm < ActiveRecord::Base
  has_many :commercial_film_tagships, dependent: :destroy
  has_many :tags, through: :commercial_film_tagships
end