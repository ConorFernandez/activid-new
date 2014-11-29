module ProjectsHelper
  def options_for_category_select
    Project::CATEGORIES.map do |k, v|
      ["#{v[:name]} - starting at $#{v[:cost]}", k]
    end
  end

  def options_for_desired_length_select
    Project::LENGTHS.map do |k, v|
      name = v[:cost] == 0 ? v[:name] : "#{v[:name]} - add $#{v[:cost]}"
      [name, k]
    end
  end

  def options_for_turnaround
    Project::TURNAROUNDS.map do |k, v|
      name = v[:cost] == 0 ? v[:name] : "#{v[:name]} (+$#{v[:cost]})"
      [name, k]
    end
  end

  def options_for_watermark
    [
      ["Activid Watermark", true],
      ["Remove Activid Logo (+$5)", false]
    ]
  end

  def step_navigation_link(project, step, step_name, active)
    if !project.persisted? || active
      content = step_name
    else
      step_path = case step
                  when 1 then project_step1_path(project)
                  when 2 then project_step2_path(project)
                  when 3 then project_step3_path(project)
                  when 4 then project_step4_path(project)
                  end

      content = link_to step_name, step_path
    end

    "<div class=\"step-block#{' selected' if active}\">#{content}</div>".html_safe
  end
end
