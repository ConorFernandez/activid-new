require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "calculated_price takes into account category, desired duration and watermark" do
    project = Project.new
    project.stubs(:category_cost).returns(3)
    project.stubs(:desired_length_cost).returns(7)
    project.watermark = false

    assert_equal (3 + 7 + 5) * 100, project.calculated_price
  end
end
