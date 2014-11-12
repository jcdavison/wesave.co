class InstitutionsController < ApplicationController
  before_filter :authenticate_user!

  def begin
    @institutions = Plaid.institutions.keys.select {|i| i.match /usaa|wells fargo/i }
  end

  def authorize
    plaid = Plaid.new
    response = plaid.initiate_auth params, current_user.email
    body = JSON.parse response.data[:body]
    institution = current_user.institutions.new token: body['access_token'],
      name: params[:institution][:type]
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

  def update
    institution = Institution.find(params[:id])
    # this is broken due to change in set_primary!
    institution.set_primary! params[:institution][:account_of_concern]
    redirect_to authenticated_root_path
  end

  private

  def route_mfa_step response, body, institution_name
    if response.status == 201
      redirect_to step_path(mfa: body["mfa"], 
                            institution_name: institution_name)
    elsif response.status == 200
      institution = current_user.institutions.find do |i|
        i.name == institution_name
      end
      institution.validate_token!
      current_user.update_banking_snapshot
      redirect_to home_path
    else
      message = "There was a problem, try again or contact jd@startuplandia.io"
      flash[:alert] = message
      redirect_to :back
    end
  end
end
