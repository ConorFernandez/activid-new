class Users::SessionsController < Devise::SessionsController
  respond_to :html, :json

  def create
    user = warden.authenticate(auth_options)

    if user
      sign_in(:user, user)

      respond_to do |format|
        format.html { redirect_to projects_path }
        format.json { render json: user, status: 201 }
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = "Email address or password was incorrect. Please try again."
          redirect_to new_user_session_path
        end

        format.json { render json: {}, status: 422 }
      end
    end
  end
end
