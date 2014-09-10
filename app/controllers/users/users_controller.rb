class Users::UsersController < Devise::RegistrationsController
  def update
    user = current_user
    user.phone_number = params[:user][:phone_number]
    user.save
    redirect_to authenticated_root_path
  end

end
