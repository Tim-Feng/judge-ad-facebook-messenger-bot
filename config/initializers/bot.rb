unless Rails.env.production?
  Dir["#{Rails.root}/app/bot/**/*.rb"].each { |file| require file }
end

Facebook::Messenger.config.access_token = Settings.access_token
Facebook::Messenger.config.verify_token = Settings.verify_token
Facebook::Messenger::Subscriptions.subscribe