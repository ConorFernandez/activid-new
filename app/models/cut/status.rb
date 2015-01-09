module Cut::Status
  class STATUS
    PROCESSING = :processing
    NEEDS_APPROVAL = :needs_approval
    ACCEPTED = :accepted
    REJECTED = :rejected
  end

  def status
    if !processed?
      STATUS::PROCESSING
    elsif accepted_at.present?
      STATUS::ACCEPTED
    elsif rejected_at.present?
      STATUS::REJECTED
    else
      STATUS::NEEDS_APPROVAL
    end
  end

  def processing?; status == STATUS::PROCESSING; end
  def needs_approval?; status == STATUS::NEEDS_APPROVAL; end
  def accepted?; status == STATUS::ACCEPTED; end
  def rejected?; status == STATUS::REJECTED; end
end
