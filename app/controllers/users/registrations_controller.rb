class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  private

  def sign_up_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation)
  end
end
