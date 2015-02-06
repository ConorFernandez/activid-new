class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  def create
    super
    Mailer.welcome_email(@user).deliver if @user.valid? && @user.user?
  end

  private

  def sign_up_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation)
  end
end
