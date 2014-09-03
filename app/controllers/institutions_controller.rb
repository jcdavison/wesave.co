class InstitutionsController < ApplicationController
  before_filter :authenticate_user!

  def begin
    @institutions = Plaid.institution_names.select {|i| i.match /usaa/i }
  end

  def authorize
    plaid = Plaid.new
    institution = current_user.institutions.new 
    response = plaid.initiate_auth params, current_user.email
    body = JSON.parse response.data[:body]
    institution.token = body["access_token"]
    institution.name = params[:institution][:type]
    institution.save
    route_mfa_step response, body, institution.name
  end

  def step
    @mfa_response = params[:mfa]
    @institution = params[:institution_name]
  end

  def mfa
    plaid = Plaid.new
    institution = current_user.institutions.find do |i|
      i.name == params[:mfa][:institution_name]
    end
    response = plaid.mfa_step params, institution
    body = JSON.parse response.data[:body]
    route_mfa_step response, body, institution.name
  end

  private

  def route_mfa_step response, body, institution_name
    if response.status == 201
      redirect_to step_path(mfa: body["mfa"], 
                            institution_name: institution_name)
    elsif response.status == 200
      redirect_to home_path
    else
      message = "There was a problem, try again or contact John."
      flash[:alert] = message
      redirect_to :back
    end
  end
end
