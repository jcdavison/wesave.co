class BudgetEventsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @budget_events = current_user.budget_events 
  end

  def create

  end

  def update

  end

  def destroy

  end
end

