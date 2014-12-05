class ErrorMailer < ActionMailer::Base
  default from: ENV['STARTUPLANDIA_GMAIL']

  def new_error args 
    @error = args[:error]
    @params = args[:params]
    mail to: ENV['WESAVE_TO'], subject: 'new error'
  end
end
