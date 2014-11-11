require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  test "POST create redirects to step 2" do
    data = {
      name: "My Project",
      category: Project::CATEGORIES.keys.first,
      desired_length: Project::LENGTHS.keys.first,
      instructions: "None"
    }

    post :create, step: 1, project: data

    project = Project.last

    assert_redirected_to project_step2_path(project)
  end
end
