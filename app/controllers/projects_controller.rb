class ProjectsController < ApplicationController
  before_filter :load_project, only: [:step1, :step2, :step3, :step4]

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to next_step(@project)
    else
      render :step1
    end
  end

  def step2
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read)
  end

  private

  def project_params
    params.require(:project).permit(:name, :category, :desired_length, :instructions, :allow_to_be_featured)
  end

  def load_project
    @project = Project.where(uuid: params[:id]).first
  end

  def next_step(project)
    case params[:step] ? params[:step].to_i : nil
    when 1 then project_step2_path(project)
    when 2 then project_step3_path(project)
    when 3 then project_step4_path(project)
    else root_path
    end
  end
end
