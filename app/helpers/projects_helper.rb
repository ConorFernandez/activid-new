module ProjectsHelper
  def display_status_for_project(project)
    if current_user && current_user.user? && project.available?
      "Waiting for Editor"
    else
      project.status.to_s.titleize
    end
  end

  def cut_due_in(project)
    t = project.cut_due_at - Time.now
    d = (t / 1.day).to_i
    h = ((t % 1.day) / 1.hour).to_i
    m = ((t % 1.hour) / 1.minute).to_i
    "#{d} Days #{h} Hours #{m} Minutes #{project.cut_due_at < Time.now ? ' ago' : nil}"
    #"#{distance_of_time_in_words_to_now(project.cut_due_at)}#{project.cut_due_at < Time.now ? ' ago' : nil}"
  end

  def options_for_category_select
    Project::CATEGORIES.map do |k, v|
      ["#{v[:name]} - starting at $#{v[:cost] / 100}", k]
    end
  end

  def options_for_desired_length_select
    Project::LENGTHS.map do |k, v|
      name = v[:cost] == 0 ? v[:name] : "#{v[:name]} - add $#{v[:cost] / 100}"
      [name, k]
    end
  end

  def options_for_turnaround
    Project::TURNAROUNDS.map do |k, v|
      name = v[:cost] == 0 ? v[:name] : "#{v[:name]} (+$#{v[:cost] / 100})"
      [name, k, {"data-price" => v[:cost]}]
    end
  end

  def options_for_append_logo
    [
      ["Activid Logo at End", true, {"data-price" => 0}],
      ["Remove Activid Logo (+$#{Project::REMOVE_LOGO_COST / 100})", false, {"data-price" => Project::REMOVE_LOGO_COST}]
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

  def options_for_music_category_select
    ActividMusic.each_with_index.map{ |c, i| "<option data-category-index=\"#{i}\">#{c["name"]}</option>" }.join.html_safe
  end

  def activid_songs
    [].tap do |songs|
      ActividMusic.each_with_index do |category, ci|
        category["songs"].each_with_index { |s, i| songs << s.merge({"category_index" => ci, "id" => "#{ci}-#{i}"}) }
      end
    end
  end
end
