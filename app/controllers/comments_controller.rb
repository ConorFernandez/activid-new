class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project

  def create
    Comment.create!(comment_params.merge(poster: current_user, project: @project))
    redirect_to project_path(@project)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def load_project
    @project = Project.where(uuid: params[:project_id]).first
    raise ActiveRecord::RecordNotFound unless @project
    raise ActiveRecord::RecordNotFound unless current_user.can_view_project?(@project)
  end
end
