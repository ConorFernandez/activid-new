require "test_helper"

class CutsControllerTest < ActionController::TestCase
  test "user can approve a cut" do
    Stripe::Charge.stubs(:create).returns(true)
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

  test "user can reject a cut if they provide a reason" do
    project = projects(:has_cuts)
    user = project.user
    cut = project.latest_cut
    reason = "needs more kittens"

    sign_in(user)

    put :reject, id: cut.id, cut: {reject_reason: reason}

    cut.reload

    assert cut.rejected?
    assert_equal reason, cut.reject_reason
  end

  test "user can't reject a cut if they don't provide a reason" do
    project = projects(:has_cuts)
    user = project.user
    cut = project.latest_cut

    sign_in(user)

    put :reject, id: cut.id

    cut.reload

    assert !cut.rejected?
    assert_equal 400, response.status
  end
end
