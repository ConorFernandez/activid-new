module ApplicationHelper
  def post_sign_up_modal_path
    if @project && params[:action] == "step4"
      project_step4_path(@project)
    else
      root_path
    end
  end

  def post_sign_in_modal_path
    if params[:controller] == "projects"
      request.path
    else
      projects_path
    end
  end
end
