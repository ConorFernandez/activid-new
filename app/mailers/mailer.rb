class Mailer < ActionMailer::Base
  helper :application, :users
  default from: "Activid <notifications@activid.co>"

  def new_editor_email(editor)
    @editor = editor
    mail(to: @editor.email, subject: "Your Activid Editor Account Has Been Created")
  end

  def failed_editor_payment_email(project, reason)
    @project = project
    @reason = reason
    @editor = project.editor
    @admins = User.all.select(&:admin?)

    mail(to: (@admins.map(&:email) + [@editor.email]), subject: "Editor payment for \"#{@project.name}\" failed")
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
end
