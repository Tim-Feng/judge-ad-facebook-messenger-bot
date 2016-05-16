class HooksController < ActionController::Base

  def messenger_verify_callback
    challenge = params["hub.challenge"]
    render json: challenge
  end

  def messenger_created_callback
    execute = ReplyService.new(params)
    execute.reply_request
    render json: "test"
  end

end