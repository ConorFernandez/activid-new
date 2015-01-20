class EditorApplicationsController < ApplicationController
  PARAM_KEYS = [:full_name, :email, :bio, :portfolio]

  def create
    if PARAM_KEYS.any?{|k| params[k].blank?}
      flash[:error] = "Please fill out the form completely."
      redirect_to new_editor_application_path
    else
      Mailer.editor_application_email(params.slice(*PARAM_KEYS)).deliver
      render action: :thank_you
    end
  end
end
