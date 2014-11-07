class Sms
  attr_accessor :from, :to, :sid, :token

  def initialize send_to_number
    @sid = ENV['TWILIO_ACCOUNT_SID']
    @token = ENV['TWILIO_AUTH_TOKEN']
    @from = ENV['TWILIO_FROM_NUMBER']
    @to = send_to_number
  end

  def self.send message, send_to_number
    sms = Sms.new send_to_number
    payload = {from: sms.from, to: sms.to, body: message}
    sms.client.account.messages.create payload
  end

  def client
    @client ||= Twilio::REST::Client.new sid, token
  end
end
