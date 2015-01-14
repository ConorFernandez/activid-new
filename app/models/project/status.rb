module Project::Status
  class STATUS
    DRAFT = :draft
    AVAILABLE = :available
    IN_PROGRESS = :in_progress
    COMPLETED = :completed
  end

  def status
    if price.nil?
      STATUS::DRAFT
    elsif latest_cut.try(:approved?)
      STATUS::COMPLETED
    elsif editor.present?
      STATUS::IN_PROGRESS
    else
      STATUS::AVAILABLE
    end
  end

  def draft?; status == STATUS::DRAFT; end
  def available?; status == STATUS::AVAILABLE; end
  def in_progress?; status == STATUS::IN_PROGRESS; end
  def completed?; status == STATUS::COMPLETED; end
end
