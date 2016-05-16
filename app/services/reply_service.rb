class ReplyService
  require "uri"
  require "net/http"
  require 'json'

  def initialize(params)
    message = params["entry"][0]["messaging"][0]
    @sender_id = message["sender"]["id"]
    @text = message["message"]["text"]
    token = ENV['fb_message_token']
    @endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + token
  end

  def reply_request
    get_data
    http_request
  end

  def get_data
    data = {
      recipient: { id: @sender_id },
      message: { text:
        "https://www.facebook.com/JudgeAd/videos/883770025050764/"
      }
    }

    @data_json = data.to_json
  end

  def http_request
    RestClient.post(@endpoint_uri, @data_json, {
      'Content-Type' => 'application/json; charset=UTF-8'
    }){ |response, request, result, &block|
      p response
      p request
      p result
    }
  end
end
