class EditorApplicationsController < ApplicationController
  PARAM_KEYS = [:full_name, :email, :city, :state, :country, :bio, :portfolio_1, :portfolio_2, :portfolio_3]

  def create
    required_keys = PARAM_KEYS - [:state]

    if required_keys.any?{|k| params[k].blank?}
      flash.now[:error] = "Please fill out the form completely."
      render action: :new
    else
      Mailer.editor_application_email(params.slice(*PARAM_KEYS)).deliver
      render action: :thank_you
    end
  end
end
