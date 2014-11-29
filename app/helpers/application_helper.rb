module ApplicationHelper
  def post_sign_in_modal_path
    if params[:controller] == "projects"
      request.path
    else
      projects_path
    end
  end

  def page_classes
    ""
  end
end
