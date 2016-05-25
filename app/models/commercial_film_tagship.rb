class CommercialFilmTagship < ActiveRecord::Base
  belongs_to :commercial_film
  belongs_to :tag
end