class InstitutionsController < ApplicationController
  def begin
    @institutions = Plaid.institution_names.select {|i| i.match /usaa/i }
  end

  def authorize
    plaid = Plaid.new
    user = User.find(current_user)
    institution = user.institutions.new 
    institution.name = params[:type]

    response = plaid.initiate_authorization params
    body = JSON.parse response.data[:body]
    institution.token = body["access_token"]
    institution.save
    if institution.save
      if response.status == 201
        redirect_to step_path(mfa: body["mfa"])
      elsif response.status == 200
        # redirect_to whatever-to-add rev exp path
      end
    else
      redirect_to :back
    end
  end

  def step
    @mfa_response = params[:mfa]
  end

  def mfa

  end

  def confirm

  end
end
