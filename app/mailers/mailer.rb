class Mailer < ActionMailer::Base
  helper :application, :users
  default from: "Activid <notifications@activid.co>",
          reply_to: "Activid <notifications@activid.co>"

  def new_editor_email(editor)
    @editor = editor
    mail(to: @editor.email, subject: "Your Activid Editor Account Has Been Created")
  end

  def new_project_created(project)
    @project = project
    @admins = User.all.select(&:admin?)
    @editors = User.all.select(&:editor?)
    @link = project_url(@project)
    mail(bcc: (@admins.map(&:email) + @editors.map(&:email)), subject: "A new project is available.")
  end

  def project_deleted(project)
    @project = project
    @editor = @project.editor
    @admins = User.all.select(&:admin?)
    @user =  @project.user
    
    mail(to: @admins.map(&:email), subject: "An admin deleted a project")

  end

  def failed_editor_payment_email(project, reason)
    @project = project
    @reason = reason
    @editor = project.editor
    @admins =User.all.select(&:admin?)

    mail(bcc: (@admins.map(&:email) + [@editor.email]), subject: "Editor payment for \"#{@project.name}\" failed")
  end

  def successful_editor_payment_email(project, amount)
    @project = project
    @amount = amount
    @editor = project.editor

    mail(to: @editor.email, subject: "A payment has been initiated to your account for a completed project")
  end

  def editor_application_email(params)
    @params = params
    @admins = User.all.select(&:admin?)

    mail(to: @admins.map(&:email), subject: "New editor application")
  end

  def new_cut_email(cut)
    @cut = cut
    @project = cut.project
    @link = project_url(@project, anchor: "cut_#{cut.id}")

    mail(to: @project.user.email, subject: "A new cut is ready for your review!")
  end

  def cut_approved_email(cut)
    @cut = cut
    @project = cut.project
    @link = final_cut_url(@project)

    mail(to: @project.user.email, subject: "Your project is complete!")
  end

  def new_comment_email(comment)
    return unless comment.commentable.is_a?(Project)

    @comment = comment
    @project = @comment.commentable
    @link = project_url(@project, anchor: "comment_#{@comment.id}")

    to_address =
      if @comment.poster.editor?
        @project.user.try(:email)
      elsif @comment.poster.user? || @comment.poster.admin?
        @project.editor.try(:email)
      end

    mail(to: to_address, subject: "A comment was posted on your project") if to_address
  end

  def cut_failed_encoding_email(cut)
    @cut = cut
    @project = cut.project
    @link = project_url(@project)

    mail(to: @project.editor.email, subject: "Error: a cut you uploaded could not be encoded")
  end

  def rejected_cut_email(cut)
    @cut = cut
    @project = cut.project

    mail(to: @project.editor.email, subject: "Another cut has been requested for one of your projects")
  end

  def cut_auto_approval_warning_email(cut)
    @cut = cut
    @project = cut.project
    @link = project_url(@project, anchor: "cut_#{cut.id}")

    mail(to: @project.user.email, subject: "The latest cut for your project is still waiting for your approval")
  end

  def cut_auto_approved_email(cut)
    @cut = cut
    @project = cut.project
    @link = final_cut_url(@project)

    mail(to: @project.user.email, subject: "Your project is complete!")
  end

  def cut_auto_approve_failed_email(cut)
    @cut = cut
    @project = cut.project
    @link = project_url(@project, anchor: "cut_#{cut.id}")
    @admins = User.all.select(&:admin?)

    mail(to: @project.user.email, cc: @admins.map(&:email), subject: "Please update your payment information")
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Activid!")
  end
end
