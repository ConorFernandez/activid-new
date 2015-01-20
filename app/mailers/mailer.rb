class Mailer < ActionMailer::Base
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

  def editor_application_email(params)
    @params = params
    @admins = User.all.select(&:admin?)

    mail(to: @admins.map(&:email), subject: "New editor application")
  end
end
