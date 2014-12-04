class CutsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_editor
  before_filter :load_project

  def create
    @cut = Cut.create!(uploader: current_user, project: @project)
    attach_file_uploads(@cut)
    redirect_to project_path(@project)
  end

  private

  def attach_file_uploads(cut)
    ids = (params[:file_upload_uuids] || [])
    cut.update(file_uploads: FileUpload.where(uuid: ids.first))
  end

  def ensure_user_is_editor
    raise ActiveRecord::RecordNotFound unless current_user.editor?
  end

  def load_project
    @project = Project.where(uuid: params[:project_id]).first
    raise ActiveRecord::RecordNotFound unless @project
    raise ActiveRecord::RecordNotFound unless current_user.can_view_project?(@project)
  end
end
