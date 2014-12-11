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

    display_hours =   seconds / 3600
    display_minutes = seconds % 3600 / 60
    display_seconds = seconds % 60

    if display_hours > 0
      "#{display_hours}:#{display_minutes.to_s.rjust(2, "0")}:#{display_seconds.to_s.rjust(2, "0")}"
    else
      "#{display_minutes}:#{display_seconds.to_s.rjust(2, "0")}"
    end
  end
end
