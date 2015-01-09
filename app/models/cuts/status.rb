module Cut::Status
  class STATUS
    PROCESSING = :processing
    PENDING = :pending
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
      STATUS::PENDING
    end
  end

  def processing?; status == STATUS::PROCESSING; end
  def pending?; status == STATUS::PENDING; end
  def accepted?; status == STATUS::ACCEPTED; end
  def rejected?; status == STATUS::REJECTED; end
end
