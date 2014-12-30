class EditorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_editor, only: :show
  before_filter :ensure_user_can_view_editor

  def index
    @editors = User.editor.all
  end

  def show
    projects = @editor.assigned_projects

    @projects = {
      completed: projects.select(&:completed?),
      in_progress: projects.select(&:in_progress?)
    }
  end

  private

  def ensure_user_can_view_editor
    raise ActiveRecord::RecordNotFound unless current_user && (current_user.admin? || current_user == @editor)
  end

  def load_editor
    @editor = User.where(id: params[:id]).first
    raise ActiveRecord::RecordNotFound unless @editor && @editor.editor?
  end
end
