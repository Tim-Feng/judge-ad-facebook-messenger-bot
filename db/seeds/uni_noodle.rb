require 'roo'

tag_list = Roo::Spreadsheet.open('./uni-noodle.xlsx')
header = tag_list.row(1)
puts "create Uni-Noodle"

(2..tag_list.last_row).each do |i|
  row = Hash[[header, tag_list.row(i)].transpose]
  noodle = UniNoodle.find_or_create_by(title: row["title"])
  noodle.update_attributes(
    video_url: row["video_url"],
    video_short_url: row["video_short_url"],
    ost_url: row["ost_url"],
    ost_short_url: row["ost_short_url"],
    recipe_url: row["recipe_url"],
    recipe_short_url: row["recipe_short_url"],
    ost_title: row["ost_title"],
    thumbnail_url: row["thumbnail_url"]
    )
end