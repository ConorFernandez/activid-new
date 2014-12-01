class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def after_sign_in_path_for(user)
    projects_path
  end

  def after_sign_up_path_for(user)
    after_sign_in_path_for(user)
  end
end
