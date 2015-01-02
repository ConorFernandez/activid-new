class Users::PasswordsController < Devise::PasswordsController
  protected

  def after_resetting_password_path_for(resource)
    if session[:project_uuid]
      @project = Project.where(uuid: session[:project_uuid]).first
    end

    if @project && @project.user.nil?
      # for when a user is not signed-in, creating a project, and has to use forgot password flow
      project_step4_path(@project)
    else
      after_sign_in_path_for(resource)
    end
  end
end

