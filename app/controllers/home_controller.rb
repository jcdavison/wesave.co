class HomeController < ApplicationController
  before_filter :authenticate_user!, except: :splash

  def index
    @institutions = current_user.institutions.valid_tokens
  end

  def splash
  end
end
