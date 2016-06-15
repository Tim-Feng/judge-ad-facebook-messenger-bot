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
      when "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10", "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20", "m21", "m22", "m23", "m24", "m25"
        register_user
        increase_tag_searched_count
        increate_user_searched_tag_and_count
        random_cf = reply_random_cf
        return bot_deliver_cf(random_cf)
      when "mh"
        bot_deliver_hot_tag
      when "ma"
        bot_deliver_tag_page_list
      when "ma1", "ma2", "ma3"
        bot_deliver_tag_by_page
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
      return "這支影片包含的主題有：" +
             "\n\n" +
             tag_list +
             "\n請挑一個您有興趣的主題，並且回傳【  】內的代碼，我將從這個主題中隨機挑三支廣告回覆給您，如果要看熱門主題，請回覆【 mh 】"
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
              title: "另開分頁觀看"
            },
            {
              type: "postback",
              title: "更多相關主題",
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
    Settings.reload!
    { text: Settings.greeting_message }
  end

  def bot_deliver_jukebox_guide_message
    Settings.reload!
    message = Settings.guide_message + "\n\n" +
              "【 mh 】熱門主題"+ "\n" +
              "【 ma 】全部主題"+ "\n\n" +
              "請回傳【  】內的代碼以獲取主題清單。"
    { text: message }
  end

  def bot_deliver_hot_tag
    Settings.reload!
    hot_tags = Tag.order(searched_count: :desc).limit(5)
    tag_list = ""
    hot_tags.each do |tag|
      tag_list = tag_list + "【m#{tag.id}】#{tag.name}" + "\n"
    end
    message = "目前的熱門主題依序是：" +
             "\n\n" +
             tag_list +
            "\n請回傳【  】內的代碼，隨機欣賞三支廣告" + "\n\n" +
            "看主題清單，請回覆【 ma 】"
    { text: message }
  end

  def bot_deliver_tag_by_page
    Settings.reload!
    tag_count     = Tag.all.count
    total_page    = (tag_count % 10 == 0) ? (tag_count / 10 ) : (tag_count / 10 + 1)
    page_of_tag   = @text.gsub("ma","").to_i
    offset_of_tag = (  page_of_tag - 1) * 10
    all_tags      = Tag.limit(10).offset(offset_of_tag)
    tag_list      = ""
    all_tags.each do |tag|
      tag_list = tag_list + "【m#{tag.id}】#{tag.name}" + "\n"
    end
    message = "以下是所有主題的第#{page_of_tag} / #{total_page}頁：" +
             "\n\n" +
             tag_list +
            "\n請回傳【  】內的代碼，隨機欣賞三支廣告。" + "\n\n" +
            "看熱門主題，請回覆【 mh 】" + "\n\n" +
            "看主題清單，請回覆【 ma 】，您目前的位置是【 #{@text} 】"
    { text: message }
  end

  def bot_deliver_tag_page_list
    message = "【 ma1 】全部主題第一頁"+ "\n" +
              "【 ma2 】全部主題第二頁"+ "\n" +
              "【 ma3 】全部主題第三頁"+ "\n\n" +
              "請回傳【  】內的代碼以獲取主題清單。"
    { text: message }
  end

end