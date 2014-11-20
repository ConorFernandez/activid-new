module ProjectsHelper
  def options_for_category_select
    Project::CATEGORIES.map do |k, v|
      ["#{v[:name]} - starting at $#{v[:starting_price]}", k]
    end
  end

  def options_for_desired_length_select
    Project::LENGTHS.map do |k, v|
      name = v[:additional_price] ? "#{v[:name]} - add $#{v[:additional_price]}" : v[:name]
      [name, k]
    end
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

    "<li style=\"display: inline-block; margin-right: 1em\">#{content}</li>".html_safe
  end
end
