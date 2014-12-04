require "avatar/view/action_view_support"

module UsersHelper
  include Avatar::View::ActionViewSupport

  def display_name_for_user(user)
    user.full_name.blank? ? user.email : user.full_name
  end

  def gravatar_url_for(user)
    avatar_url_for(user)
  end
end
