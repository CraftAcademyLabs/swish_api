Rails.application.routes.draw do
  post 'swish/payments', controller: :swish, action: :create_payment
  post 'swish/callback', controller: :swish, action: :callback
end
