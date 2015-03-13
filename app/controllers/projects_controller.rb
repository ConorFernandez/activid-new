class ProjectsController < ApplicationController
  before_filter :load_project, only: [:show, :update, :step1, :step2, :step3, :step4, :claim, :final_cut, :fix_card]
  before_filter :ensure_project_is_editable, only: [:update, :step1, :step2, :step3, :step4]
  before_filter :ensure_not_editor, only: [:new, :create, :step1, :step2, :step3, :step4, :fix_card]
  before_filter :authenticate_user!, except: [:new, :create, :step1, :step2, :step3, :step4, :update, :final_cut, :fix_card]
  before_filter :store_project_in_session

  def new
    @project = Project.new
  end

  def destroy
    @project = Project.where(uuid: params[:id]).first
    Mailer.project_deleted(@project).deliver
    @project.destroy
    redirect_to(projects_path)
  end

  def index
    if current_user.user?
      @projects = current_user.projects.order("created_at DESC")
      return redirect_to(new_project_path) if @projects.empty?
    elsif current_user.editor?
      @available = Project.where(editor_id: nil).select{|p| p.available?}
      @completed, @current = current_user.assigned_projects.partition(&:completed?)

      render :editor_index
    elsif current_user.admin?
      if params[:email] && user = User.where(email: params[:email]).first
        @all = user.projects.order("created_at DESC").all.select{ |p| !p.draft? }
      else
        @all = Project.order("created_at DESC").all.select{ |p| !p.draft? }
      end

      @available = @all.select(&:available?)
      @in_progress = @all.select(&:in_progress?)
      @completed = @all.select(&:completed?)

      render :admin_index
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
      attach_file_uploads(@project)       if current_step == 2 || current_step == 3
      attach_activid_music(@project)      if current_step == 3
      set_payment_method(@project)        if @project.user.present? && (params[:stripe_token].present? || params[:stripe_card_id].present?)

      return redirect_to(project_step4_path(@project)) if current_step == 4 && @card_error

      @project.submit!                    if current_step == 4 && @project.submittable?

      redirect_to next_step_path(@project)
    else
      render current_step_action
    end
  end

  def final_cut
    raise ActiveRecord::RecordNotFound unless @project.completed?
  end

  def claim
    raise ActiveRecord::RecordNotFound unless @project.editor.nil? && current_user.can_accept_projects?

    @project.update(editor: current_user)

    redirect_to project_path(@project)
  end

  def fix_card
    if @project.user.present? && params[:stripe_token].present?
      set_payment_method(@project)
      @project.latest_cut.approve! if @project.latest_cut.try(:needs_approval?)
    end
  rescue Stripe::CardError => e
    flash[:error] = "There was a problem with your card: #{e.message}"
  ensure
    redirect_to project_path(@project)
  end

  private

  def project_params
    if params[:project].present?
      params.require(:project).permit(:name, :category, :desired_length, :instructions, :allow_to_be_featured, :append_logo, :turnaround)
    else
      {}
    end
  end

  def load_project
    @project = Project.where(uuid: params[:id]).first

    if current_user
      raise ActiveRecord::RecordNotFound unless current_user.can_view_project?(@project)
    else
      # non-users can only view projects that don't belong to anyone or are public
      raise ActiveRecord::RecordNotFound unless @project.user.nil? || @project.completed?
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
    ids = params[:file_upload_uuids] || []
    new_uploads = ids.map{|id| FileUpload.where(uuid: id).first}

    uploads_to_keep =
      if current_step == 2
        project.music_uploads 
      elsif current_step == 3
        project.video_uploads + project.image_uploads
      else
        []
      end

    project.update(file_uploads: new_uploads + uploads_to_keep)
  end

  def set_payment_method(project)
    if project.user.stripe_customer_id.blank?
      # new card, new customer
      customer = Stripe::Customer.create(
        :card => params[:stripe_token],
        :description => project.user.email
      )

      project.user.update(stripe_customer_id: customer.id)

      card = customer.cards.first
    elsif params[:stripe_token]
      # new card, existing customer
      card = project.user.stripe_customer.cards.create(card: params[:stripe_token])
    elsif params[:stripe_card_id]
      # existing card, existing customer
      card = project.user.stripe_customer.cards.retrieve(params[:stripe_card_id])
    end

    project.update(stripe_card_id: card.id)
  rescue Stripe::InvalidRequestError => e
    return false
  rescue Stripe::CardError => e
    @card_error = true
    flash[:error] = "There was a problem with your card: #{e.message}"
    return false
  end

  def ensure_not_editor
    raise ActiveRecord::RecordNotFound if current_user && !current_user.user?
  end

  def store_project_in_session
    session[:project_uuid] = @project.uuid if @project && @project.uuid.present?
  end

  def attach_activid_music(project)
    urls = params[:activid_music_urls] || []
    project.update(activid_music_urls: urls.uniq)
  end
end
