require "test_helper"

class CutsControllerTest < ActionController::TestCase
  test "user can approve a cut" do
    project = projects(:has_cuts)
    user = project.user
    cut = project.latest_cut

    sign_in(user)

    assert !cut.approved?

    put :approve, id: cut.id

    assert cut.reload.approved?
  end

  test "user can't approve a cut that doesn't belong to them" do
    project = projects(:has_cuts)
    user = users(:wilson)
    cut = project.latest_cut

    sign_in(user)

    assert_raises ActiveRecord::RecordNotFound do
      put :approve, id: cut.id
    end
  end

  test "user can't approve a cut that doesn't need approval" do
    project = projects(:has_cuts)
    user = project.user
    cut = project.first_cut

    sign_in(user)

    assert_raises ActiveRecord::RecordNotFound do
      put :approve, id: cut.id
    end
  end
end
