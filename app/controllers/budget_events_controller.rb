class BudgetEventsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @revenues = current_user.budget_events.revenues
    @expenses = current_user.budget_events.expenses
  end

  def create
    budget_event = params[:budget_event]
    current_user.budget_events.create(description: budget_event[:description], 
                      value: budget_event[:value],
                      month_day: budget_event[:month_day])
    redirect_to events_path
  end

  def update

  end

  def destroy
    BudgetEvent.find(params[:id]).destroy
    redirect_to events_path
  end
end

