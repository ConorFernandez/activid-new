module ApplicationHelper
  def post_sign_in_modal_path
    if params[:controller] == "projects"
      request.path
    else
      projects_path
    end
  end

  def page_classes
    params[:action]
  end

  def add_page_class(klass)
    @page_classes ||= []
    @page_classes << klass
  end

  def page_classes
    (@page_classes || []).uniq.join(" ")
  end
end
