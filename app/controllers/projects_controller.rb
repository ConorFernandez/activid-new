class ProjectsController < ApplicationController
  before_filter :load_project, only: [:show, :update, :step1, :step2, :step3, :step4, :claim]
  before_filter :ensure_project_is_editable, only: [:update, :step1, :step2, :step3, :step4]
  before_filter :authenticate_user!, except: [:new, :create, :step1, :step2, :step3, :step4, :update]

  def new
    @project = Project.new
  end

  def index
    if current_user.user?
      @projects = current_user.projects.order("created_at DESC")
    elsif current_user.editor?
      @available = Project.where(editor_id: nil).select{|p| p.submitted?}
      @completed, @current = current_user.assigned_projects.partition(&:completed?)

      render :editor_index
    else
      @projects = []
    end
  end

  def create
    @project = Project.new(project_params.merge(user: current_user))

    if @project.save
      redirect_to next_step_path(@project)
    else
      render current_step_action
    end
  end

  def step4
    # capture project on user's account if they sign up during project creation flow
    @project.update(user: current_user) if @project.user.nil? && current_user.present?
  end

  def update
    if @project.update(project_params)
      @project.update(user: current_user) if @project.user.nil? && current_user.present? && current_user.user?
      attach_file_uploads(@project)       if current_step == 2
      attach_payment_method(@project)     if params[:payment_method_token].present?
      @project.submit!                    if current_step == 4 && @project.payment_method.present? && @project.user.present?

      redirect_to next_step_path(@project)
    else
      render current_step_action
    end
  end

  def claim
    raise ActiveRecord::RecordNotFound unless current_user.editor? && @project.editor.nil?

    @project.update(editor: current_user)

    redirect_to project_path(@project)
  end

  def presigned_post
    presigned_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read)

    render json: {
      post_url: presigned_post.url.to_s,
      form_data: presigned_post.fields,
      remote_host: presigned_post.url.host
    }
  end

  private

  def project_params
    if params[:project].present?
      params.require(:project).permit(:name, :category, :desired_length, :instructions, :allow_to_be_featured, :watermark, :turnaround)
    else
      {}
    end
  end

  def load_project
    @project = Project.where(uuid: params[:id]).first

    # todo: move this into user or project model
    if current_user
      if current_user.user?
        # current users can only view their own projects and projects that don't belong to anyone
        raise ActiveRecord::RecordNotFound unless @project.user.nil? || @project.user == current_user
      elsif current_user.editor?
        # editors can only view their assigned projects and submitted projects
        raise ActiveRecord::RecordNotFound unless @project.submitted? || @project.editor == current_user
      end
    else
      # non-users can only view projects that don't belong to anyone
      raise ActiveRecord::RecordNotFound unless @project.user.nil?
    end
  end

  def ensure_project_is_editable
    raise ActiveRecord::RecordNotFound unless @project.draft?
  end

  def next_step_path(project)
    case current_step
    when 1 then project_step2_path(project)
    when 2 then project_step3_path(project)
    when 3 then project_step4_path(project)
    else current_user ? projects_path : project_step4_path(project)
    end
  end

  def current_step_action
    (1..4).include?(current_step) ? "step#{current_step}".to_sym : raise("Could not determine current step action")
  end

  def current_step
    params[:step].try(:to_i)
  end

  def attach_file_uploads(project)
    ids = (params[:file_upload_uuids] || [])
    project.update(file_uploads: ids.map{|id| FileUpload.where(uuid: id).first})
  end

  def attach_payment_method(project)
    payment_method = PaymentMethod.create!(token: params[:payment_method_token])
    project.update(payment_method: payment_method)
  end
end
