require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users(:joey)
  end

  test "user can change name without providing password" do
    sign_in(@user)

    assert_not_equal "Sexton Hardcastle", @user.full_name

    put :update, user: {full_name: "Sexton Hardcastle"}

    assert_redirected_to projects_path
    assert_equal "Sexton Hardcastle", @user.reload.full_name
  end

  test "user cannot change password without confirmation" do
    sign_in(@user)

    put :update, user: {password: "asdfasdf"}

    assert_template :edit
    assert !flash[:error].blank?
  end

  test "user can change password with confirmation" do
    sign_in(@user)
    old_hash = @user.encrypted_password

    put :update, user: {password: "asdfasdf", password_confirmation: "asdfasdf"}

    assert_redirected_to projects_path
    assert_not_equal old_hash, @user.reload.encrypted_password
  end

  test "adds bank account if user is editor and token is provided" do
    user = users(:editor1)
    sign_in user

    mock_recipient = OpenStruct.new(
      id: "recipient_id",
      active_account: OpenStruct.new(last4: "1234")
    )

    Stripe::Recipient.expects(:create).returns(mock_recipient)

    put :update, user: {password: ""}, bank_account_token: "asdf"

    user.reload
    assert_equal "recipient_id", user.stripe_recipient_id
    assert_equal "1234", user.bank_account_last_four
  end
end
