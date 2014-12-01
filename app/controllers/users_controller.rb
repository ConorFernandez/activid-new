class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      sign_in(@user, bypass: true)
      flash[:success] = "Your account has been updated."
      redirect_to projects_path
    else
      flash.now[:error] = "There was a problem updating your account: #{@user.errors.full_messages.to_sentence.downcase}."
      render action: :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
