unless Rails.env.production?
  Dir["#{Rails.root}/app/bot/**/*.rb"].each { |file| require file }
end
Settings.reload!

Facebook::Messenger.config.access_token = Settings.access_token
Facebook::Messenger.config.verify_token = Settings.verify_token
Facebook::Messenger::Subscriptions.subscribe
# Facebook::Messenger::Welcome.set text: Settings.welcome_message