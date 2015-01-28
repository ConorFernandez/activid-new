class CutsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project, only: :create
  before_filter :ensure_user_is_editor, only: :create

  before_filter :load_cut, only: [:approve, :reject]
  before_filter :ensure_cut_needs_approval, only: [:approve, :reject]

  def create
    @cut = Cut.new(uploader: current_user, project: @project)
    attach_file_upload(@cut)
    @cut.save!

    check_for_cuts_to_cancel(@project)

    redirect_to project_path(@project)
  end

  def approve
    if @cut.approve!
      render json: {path: project_path(@cut.project)}
    else
      head :bad_request
    end
  end

  def reject
    if @cut.reject!(params[:cut].try(:[], :reject_reason))
      Mailer.rejected_cut_email(@cut).deliver
      render json: {path: project_path(@cut.project)}
    else
      head :bad_request
    end
  end

  private

  def attach_file_upload(cut)
    ids = (params[:file_upload_uuids] || [])
    cut.file_upload = FileUpload.where(uuid: ids.first).first
  end

  def ensure_user_is_editor
    raise ActiveRecord::RecordNotFound unless current_user.editor? && current_user == @project.editor
  end

  def ensure_cut_needs_approval
    raise ActiveRecord::RecordNotFound unless @cut.needs_approval?
  end

  def load_project
    @project = Project.where(uuid: params[:project_id]).first
    raise ActiveRecord::RecordNotFound unless @project
    raise ActiveRecord::RecordNotFound unless current_user.can_view_project?(@project)
  end

  def load_cut
    @cut = Cut.find(params[:id])
    raise ActiveRecord::RecordNotFound unless current_user.can_view_cut?(@cut)
  end

  def check_for_cuts_to_cancel(project)
    if project.cuts.count > 1
      previous_cut = project.cuts[-2]
      previous_cut.delete if previous_cut.needs_approval?
    end
  end
end
