class MatchTagService
  def match(sender_id, message)
    @text      = message
    @sender_id = sender_id
    # if matched, record which user searched what tag,
    # if not matched, return nothing
    begin
      case @text
      when "阿福"
        bot_deliver_greeting_message
      when "m"
        bot_deliver_jukebox_guide_message
      when "m1", "m2", "m3", "m4", "m5"
        register_user
        increase_tag_searched_count
        increate_user_searched_tag_and_count
        random_cf = reply_random_cf
        return bot_deliver_cf(random_cf)
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
        tag_list = tag_list + "- 【m#{tag.id}】#{tag.name}" + "\n"
      end
      return "這支影片的標籤有：" +
             "\n\n" +
             tag_list +
             "\n請挑一個您有興趣的標籤，並且回傳【 】內的代碼，我將從這個標籤中隨機挑三支廣告回覆給您"
    end
  end

  def reply_random_cf
    if @tag
      random_cf = @tag.commercial_films.where(id: @tag.commercial_films.pluck(:id).sample(3))
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

  def register_user
    User.find_or_create_by(facebook_user_id: @sender_id)
  end

  def increase_tag_searched_count
    tag_id = @text.gsub('m', '').to_i
    @tag = Tag.find(tag_id) if tag_id != 0
    @tag.searched_count += 1
    @tag.save
  end

  def increate_user_searched_tag_and_count
    user = User.find_by(facebook_user_id: @sender_id)
    user.searched_tag_and_count = {}
    count = {}
    user.searched_tag_and_count[@tag.name] ? user.searched_tag_and_count[@tag.name] += 1 : count[@tag.name] = 1
    user.searched_tag_and_count.merge!(count)
    user.save
  end

  def bot_deliver_cf(random_cf)
    {
      attachment: {
        type: "template",
        payload: {
          template_type: "generic",
          elements: random_cf
        }
      }
    }
  end

  def bot_deliver_greeting_message
    { text: Settings.greeting_message }
  end

  def bot_deliver_jukebox_guide_message
    hot_tags = Tag.order(searched_count: :desc).limit(5)
    tag_list = ""
    hot_tags.each do |tag|
      tag_list = tag_list + "- 【m#{tag.id}】#{tag.name}" + "\n"
    end
    message = Settings.guide_message +
             "\n\n" +
             tag_list +
            "\n請挑一個您有興趣的標籤，並且回傳【 】內的代碼，我將從這個標籤中隨機挑三支廣告回覆給您"
    { text: message }
  end

end