Rails.application.routes.draw do
  mount Facebook::Messenger::Server, at: 'bot'
  root 'welcome#index'
end
