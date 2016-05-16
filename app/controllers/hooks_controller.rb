class HooksController < ActionController::Base

  def messenger_verify_callback
    challenge = params["hub.challenge"]
    render json: challenge
  end

end