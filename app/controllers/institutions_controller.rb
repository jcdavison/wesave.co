class InstitutionsController < ApplicationController
  def begin
    @institutions = Plaid.institution_names
  end

  def authorize
  
  end

  def step

  end

  def confirm

  end
end
