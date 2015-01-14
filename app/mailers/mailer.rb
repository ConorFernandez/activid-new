class Mailer < ActionMailer::Base
  default from: "Activid <notifications@activid.co>"

  def new_editor_email(editor)
    @editor = editor
    mail(to: @editor.email, subject: "Your Activid Editor Account Has Been Created")
  end
end
