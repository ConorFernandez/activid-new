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

  def duration(seconds)
    return "0:00" if seconds.nil?

    display_minutes = seconds / 60
    display_seconds = seconds % 60

    "#{display_minutes}:#{display_seconds.to_s.rjust(2, "0")}"
  end
end
