class MatchTagService

  def initialize(message)
    @text      = message.text
    @sender_id = message.sender["id"]
  end

  def match
    # if matched, record which user searched what tag,
    # if not matched, return nothing
    case @text
    when "m1"
      return "https://www.facebook.com/JudgeAd/videos/1029729767121455/"
    end
  end
end