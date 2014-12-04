module UsersHelper
  def display_name_for_user(user)
    user.full_name.blank? ? user.email : user.full_name
  end
end
