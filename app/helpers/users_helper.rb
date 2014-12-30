require "avatar/view/action_view_support"

module UsersHelper
  include Avatar::View::ActionViewSupport

  def display_name_for_user(user)
    user.full_name.blank? ? user.email : user.full_name.split(" ").first
  end

  def long_display_name_for_user(user)
    user.full_name.presence || user.email
  end

  def gravatar_url_for(user)
    url = avatar_url_for(user)

    if url.match(/\?/) # already has a query param
      url += "&d=mm"
    else
      url += "?d=mm"
    end
  end
end
