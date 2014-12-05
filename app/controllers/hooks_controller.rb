class HooksController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:hook]
  def hook
    begin 
      process_hook params
    rescue => e
      ErrorMailer.new_error(e, params).deliver
    end
    head 200, content_type: "text/html"
  end

  private
  def process_hook params
    if (0..2).include? params[:code]
      update_user_info params
    elsif params[:code] == 3
      remove_transactions params[:removed_transactions]
    end
  end

  def update_user_info params
    Institution.find_by_token(token(params)).user.update_banking_snapshot
  end

  def token params
    params[:access_token]
  end

  def remove_transactions transaction_ids
    transaction_ids.each {|id| Transaction.find(id).destroy}
  end
end
