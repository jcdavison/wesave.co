class InstitutionsController < ApplicationController
  def begin
    @institutions = Plaid.institution_names.select {|i| i.match /usaa/i }
  end

  def authorize
    plaid = Plaid.new
    user = User.find(current_user)
    institution = user.institutions.new 
    institution.name = params[:institution][:type]

    response = plaid.initiate_authorization params
    body = JSON.parse response.data[:body]
    institution.token = body["access_token"]
    institution.save
    if institution.save
      if response.status == 201
        redirect_to step_path(mfa: body["mfa"])
      elsif response.status == 200
        redirect_to home_path
      end
    else
      redirect_to :back
    end
  end

  def step
    @mfa_response = params[:mfa]
  end

  def mfa
    plaid = Plaid.new
    institution = current_user.institutions.last
    response = plaid.mfa_step params, institution
    body = JSON.parse response.data[:body]
    route_mfa_step response, body
  end

  private

  def route_mfa_step response, body
    if response.status == 201
      redirect_to step_path(mfa: body["mfa"])
    elsif response.status == 200
      redirect_to home_path
    else
      redirect_to :back
    end
  end
end
