include Facebook::Messenger

Bot.on :message do |message|
  message.id
  message.sender
  message.seq
  message.text

  Rails.logger.info { "[Process Begins] #{Time.now}" }
  if message.messaging["message"]["quick_reply"]
    exact_message = message.messaging["message"]["quick_reply"]["payload"]
  elsif message.text
    exact_message = message.text.downcase
  end

  if exact_message
    result = MatchTagService.new.match(message.sender["id"], exact_message)
   # if matched, then return bot message, or return nothing
    begin
      if result
        Bot.deliver(
          recipient: message.sender,
          message: result
        )
      else
      end
    rescue => e
    end
  end
  Rails.logger.info { "[Process Ends] #{Time.now}" }

end
Bot.on :postback do |postback|
  postback.sender    # => { 'id' => '1008372609250235' }
  postback.recipient # => { 'id' => '2015573629214912' }
  postback.sent_at   # => 2016-04-22 21:30:36 +0200
  postback.payload   # => 'EXTERMINATE'
  if postback.payload.include? 'CF_TAGS_OF_'
    result = MatchTagService.new.find_tags(postback.payload)
    Bot.deliver(
      recipient: postback.sender,
      message: result
    )
  end
end
