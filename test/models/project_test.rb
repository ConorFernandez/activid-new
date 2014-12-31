require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  test "calculated_price takes into account category, desired duration, uploaded_footage, and append_logo" do
    project = Project.new
    project.stubs(:category_cost).returns(3)
    project.stubs(:desired_length_cost).returns(5)
    project.stubs(:remove_logo_cost).returns(7)
    project.stubs(:uploaded_footage_cost).returns(9)
    project.stubs(:turnaround_time_cost).returns(11)

    assert_equal (3 + 5 + 7 + 9 + 11), project.calculated_price
  end
end
