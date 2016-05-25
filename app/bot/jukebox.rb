include Facebook::Messenger

Bot.on :message do |message|
  message.id
  message.sender
  message.seq
  message.text

  result = MatchTagService.new(message).match
  # if matched, then return bot message, or return nothing
  if result
    Bot.deliver(
      recipient: message.sender,
      message: {
        attachment: {
          type: "template",
          payload: {
            template_type: "generic",
            elements: result
          }
        }
      }
    )
  else
  end
end
