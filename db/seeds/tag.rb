require 'roo'

tag_list = Roo::Spreadsheet.open('./tag.xlsx')
header = tag_list.row(1)
puts "create Tag"

(2..tag_list.last_row).each do |i|
  row = Hash[[header, tag_list.row(i)].transpose]
  Tag.find_or_create_by(name: row["name"])
end