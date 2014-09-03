class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    @institutions = current_user.institutions.valid_tokens
  end
end
