class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_commentable

  def create
    attributes = comment_params.merge(
      poster: current_user,
      commentable: @commentable
    ).tap{|h| h.delete(:commentable_uuid)}

    Comment.create!(attributes)

    if @commentable.is_a?(User)
      redirect_to editor_path(@commentable)
    else
      redirect_to @commentable
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :commentable_uuid)
  end

  def load_commentable
    case comment_params[:commentable_type]
    when "Project"
      @commentable = Project.where(uuid: comment_params[:commentable_uuid]).first
      raise ActiveRecord::RecordNotFound unless current_user.can_view_project?(@commentable)
    when "User"
      @commentable = User.find(comment_params[:commentable_id])
      raise ActiveRecord::RecordNotFound unless current_user.admin? || current_user == @commentable
    end

    raise ActiveRecord::RecordNotFound unless @commentable
  end
end
