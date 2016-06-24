require 'roo'

cf_list = Roo::Spreadsheet.open('./commercial-film.xlsx')
header = cf_list.row(1)
puts "create Commercial Film"
ActiveRecord::Base.connection.execute("TRUNCATE commercial_film_tagships")

def self.create_association_of_cf_and_tag(tag_data, cf)
  tags = tag_data.split(",") if tag_data
  if tags
    tags.each do |tag|
      tag_id = Tag.find_by_name(tag).id
      CommercialFilmTagship.find_or_create_by(commercial_film_id: cf.id, tag_id: tag_id)
    end
  end
end

(2..cf_list.last_row).each do |i|
  row      = Hash[[header, cf_list.row(i)].transpose]
  tag_data = row["tag"]
  cf       = CommercialFilm.find_or_create_by(title: row["title"], video_url: row["video_url"])
  create_association_of_cf_and_tag(tag_data, cf)
  cf.update(thumbnail_url: row["thumbnail_url"])
  cf.update(short_url: row["short_url"])
end
