namespace :auto_approve_cuts do
  desc "Warn users who have a week-old cut"
  task :send_warnings do
    cuts = Cut.where("processed_at < ?", 1.week.ago).where(user_warned_of_auto_approval_at: nil).all.select(&:needs_approval?)

    cuts.each do |cut|
      Mailer.cut_auto_approval_warning_email(cut).deliver
      cut.update(user_warned_of_auto_approval_at: Time.now)
    end
  end

  desc "Auto-approve cuts that are two weeks old"
  task :approve do
    cuts = Cut.where("processed_at < ?", 2.weeks.ago).where(approved_at: nil, failed_auto_approve_at: nil).all.select(&:needs_approval?)

    cuts.each do |cut|
      if cut.approve!
        Mailer.cut_auto_approved_email(cut).deliver
      else
        cut.update(failed_auto_approve_at: Time.now)
        Mailer.cut_auto_approve_failed_email(cut).deliver
      end
    end
  end
end
