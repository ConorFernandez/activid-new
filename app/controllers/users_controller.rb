class UsersController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      sign_in(@user, bypass: true)
      update_stripe_recipient if @user.editor? && params[:bank_account_token].present?

      flash[:success] = "Your account has been updated."
      redirect_to projects_path
    else
      flash.now[:error] = "There was a problem updating your account: #{@user.errors.full_messages.first.downcase}."
      render action: :edit
    end
  end

  private

  def user_params
    user_keys = [:full_name]
    password_keys = [:password, :password_confirmation]

    if params[:user][:password].blank?
      params.require(:user).permit(user_keys)
    else
      params[:user][:password_confirmation] ||= ""
      params.require(:user).permit(user_keys + password_keys)
    end
  end

  def update_stripe_recipient
    recipient = Stripe::Recipient.create(
      :name => @user.full_name,
      :type => "individual",
      :email => @user.email,
      :bank_account => params[:bank_account_token]
    )

    @user.update(
      stripe_recipient_id: recipient.id,
      bank_account_last_four: recipient.active_account.last4
    )
  end
end
