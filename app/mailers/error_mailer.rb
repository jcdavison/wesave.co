class ErrorMailer < ActionMailer::Base
  default from: ENV['STARTUPLANDIA_GMAIL']

  def new_error error, params
    @error = error
    @params = params
    mail to: ENV['WESAVE_TO'], subject: 'new error'
  end
end
