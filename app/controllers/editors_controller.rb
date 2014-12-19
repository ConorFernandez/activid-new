class EditorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_admin

  def index
    @editors = User.editor.all
  end

  private

  def ensure_user_is_admin
    unless current_user && current_user.admin?
      return redirect_to(root_path)
    end
  end
end
