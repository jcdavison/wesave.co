if Rails.env.development?
  WEBHOOK = 'https://wesave.ngrok.com/hooks'
else
  WEBHOOK = 'https://wesave.herokuapp.com/hooks'
end
