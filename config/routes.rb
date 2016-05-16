Rails.application.routes.draw do
  root 'welcome#index'
  get '/hooks' => 'hooks#messenger_verify_callback'

end
