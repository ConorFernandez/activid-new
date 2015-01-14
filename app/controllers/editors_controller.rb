class EditorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  before_filter :load_editor, only: [:show, :pause, :unpause]

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

  def new
    @editor = User.new(role: "editor")
  end

  def create
    @editor = User.new(editor_params.merge(role: "editor", password: "changeme", password_confirmation: "changeme"))

    if @editor.save
      Mailer.new_editor_email(@editor).deliver
      flash[:success] = "An editor account for #{@editor.email} was created"
      redirect_to editors_path
    else
      render action: :new
    end
  end

  def pause
    @editor.update(paused: true)
    redirect_to editor_path(@editor)
  end

  def unpause
    @editor.update(paused: false)
    redirect_to editor_path(@editor)
  end

  private

  def ensure_admin
    raise ActiveRecord::RecordNotFound unless current_user.admin?
  end

  def load_editor
    @editor = User.where(id: params[:id]).first
    raise ActiveRecord::RecordNotFound unless @editor && @editor.editor?
  end

  def editor_params
    params.require(:editor).permit(:email, :full_name)
  end
end
