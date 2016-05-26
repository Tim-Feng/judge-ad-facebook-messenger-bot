class MatchTagService
  def match(sender_id, message)
    @text      = message
    @sender_id = sender_id
    # if matched, record which user searched what tag,
    # if not matched, return nothing
    begin
      case @text
      when "m1", "m2", "m3", "m4", "m5"
        reply_random_cf
      end
    rescue => e
      return
    end
  end

  def find_tags(payload)
    cf_id    = payload.gsub('CF_TAGS_OF_', '').to_i
    tags     = CommercialFilm.find(cf_id).tags
    tag_list = ""
    if tags
      tags.each do |tag|
        tag_list = tag_list + "- #{tag.name}【m#{tag.id}】" + "\n"
      end
      return "這支影片的標籤有：" +
             "\n\n" +
             tag_list +
             "\n請挑一個您有興趣的標籤，並且回傳【 】內的代碼，我將從這個標籤中隨機挑三支廣告回覆給您"
    end
  end

  def reply_random_cf
    tag_id = @text.gsub('m', '').to_i
    tag = Tag.find(tag_id) if tag_id != 0
    if tag
      random_cf = tag.commercial_films.where(id: tag.commercial_films.pluck(:id).sample(3))
      # random_cf is an array
      random_cf.map do |cf|
        {
          title: cf.title,
          image_url: cf.thumbnail_url,
          buttons:[
            {
              type: "web_url",
              url: cf.video_url,
              title: "立刻觀看"
            },
            {
              type: "postback",
              title: "影片標籤",
              payload: "CF_TAGS_OF_#{cf.id}"
            }
          ]
        }
      end
    end
  end

end