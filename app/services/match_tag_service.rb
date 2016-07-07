class MatchTagService
  def match(sender_id, message)
    @text      = message
    @sender_id = sender_id
    # if matched, record which user searched what tag,
    # if not matched, return nothing
    begin
      return message_for_including_parentheses if is_message_with_parentheses?
      return message_for_m_in_chinese if is_message_with_m_in_chinese?
      return thank_you_message if is_message_thank_you?

      case @text
      when "阿福", "hi", "嗨", "哈囉"
        greeting
      when "m"
        reply_jukebox_guide
      when "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10", "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20", "m21", "m22", "m23", "m24", "m25", "m26"
        register_user
        increase_tag_searched_count
        increate_user_searched_tag_and_count
        random_cf = reply_random_cf
        return bot_deliver_cf(random_cf)
      when "mh"
        reply_hot_tag
      when "ma"
        reply_tag_page_list
      when "ma1", "ma2", "ma3"
        reply_tag_by_page
      when "noodle", "統一麵"
        cf = reply_noodle
        return bot_deliver_cf(cf)
      when "comment"
        comment = comment_from_judge
        return bot_deliver_cf(comment)
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
              url: cf.short_url,
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

  def bot_deliver_cf(cf)
    {
      attachment: {
        type: "template",
        payload: {
          template_type: "generic",
          elements: cf
        }
      }
    }
  end

  def reply_noodle
    series = UniNoodle.all
    series.map do |serie|
      {
        title: serie.title,
        image_url: serie.thumbnail_url,
        buttons:[
          {
            type: "web_url",
            url: serie.video_short_url,
            title: "觀賞影片"
          },
          {
            type: "web_url",
            url: serie.ost_short_url,
            title: "欣賞配樂"
          },
          {
            type: "web_url",
            url: serie.recipe_short_url,
            title: "食譜詳解"
          }
        ]
      }
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


  def greeting
    Settings.reload!
    { text: Settings.greeting_message }
  end

  def reply_jukebox_guide
    Settings.reload!
    message = Settings.guide_message + "\n\n" +
              "【 mh 】熱門主題"+ "\n" +
              "【 ma 】全部主題"+ "\n\n" +
              "請回傳【  】內的代碼以獲取主題清單。"
    { text: message }
  end

  def reply_hot_tag
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

  def reply_tag_by_page
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

  def reply_tag_page_list
    message = "【 ma1 】全部主題第一頁"+ "\n" +
              "【 ma2 】全部主題第二頁"+ "\n" +
              "【 ma3 】全部主題第三頁"+ "\n\n" +
              "請回傳【  】內的代碼以獲取主題清單。"
    { text: message }
  end

  def is_message_with_parentheses?
    ["(", ")", "【", "】", "（", "）", "“", "\""].any? { |sign| @text.include? sign }
  end

  def is_message_thank_you?
    ["thank", "thanks.", "謝謝", "感謝", "感恩", "thx", "謝拉", "謝啦"].any? { |sign| @text.include? sign }
  end

  def is_message_with_m_in_chinese?
    @text.include?("Ｍ")
  end

  def message_for_including_parentheses
    Settings.reload!
    { text: Settings.remove_parentheses }
  end

  def message_for_m_in_chinese
    Settings.reload!
    { text: Settings.m_in_chinese }
  end

  def thank_you_message
    Settings.reload!
    { text: Settings.thank_you_message.sample }
  end

  def comment_from_judge
    [
      {
        title: "坎城評審講評",
        image_url: "http://user-image.logdown.io/user/16748/blog/16108/post/734429/kFyeF3oxQB6ywKZJkfGF_424.jpg",
        buttons:[
          {
            type: "web_url",
            url: "http://bit.ly/28Wkxnx",
            title: "觀賞講評"
          }
        ]
      }
    ]
  end
end