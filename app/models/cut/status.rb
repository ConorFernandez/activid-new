module Cut::Status
  class STATUS
    PROCESSING = :processing
    NEEDS_APPROVAL = :needs_approval
    APPROVED = :approved
    REJECTED = :rejected
  end

  def status
    if !processed?
      STATUS::PROCESSING
    elsif approved_at.present?
      STATUS::APPROVED
    elsif rejected_at.present?
      STATUS::REJECTED
    else
      STATUS::NEEDS_APPROVAL
    end
  end

  def processing?; status == STATUS::PROCESSING; end
  def needs_approval?; status == STATUS::NEEDS_APPROVAL; end
  def approved?; status == STATUS::APPROVED; end
  def rejected?; status == STATUS::REJECTED; end
end
