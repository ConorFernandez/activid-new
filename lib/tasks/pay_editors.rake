desc "Look for projects that need to pay out to editors"
task pay_editors: :environment do
  Project.where(attempted_to_pay_editor_at: nil).all.select(&:completed?).each do |project|
    begin
      transfer = project.pay_editor!

      if transfer.try(:failure_message).present?
        Mailer.failed_editor_payment_email(project, transfer.failure_message).deliver
      elsif transfer.try(:amount)
        Mailer.successful_editor_payment_email(project, transfer.amount).deliver
      end
    rescue => e
      Mailer.failed_editor_payment_email(project, e.inspect).deliver
    ensure
      project.update(attempted_to_pay_editor_at: Time.now)
    end
  end
end
