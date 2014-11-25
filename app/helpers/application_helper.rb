module ApplicationHelper
  def post_sign_in_modal_path
    if @project && params[:action] == "step4"
      project_step4_path(@project)
    else
      root_path
    end
  end
end
