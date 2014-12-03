module Project::Status
  class STATUS
    DRAFT = :draft
    SUBMITTED = :submitted
    IN_PROGRESS = :in_progress
    COMPLETED = :completed
  end

  def status
    if price.nil?
      STATUS::DRAFT
    elsif editor.present?
      STATUS::IN_PROGRESS
    else
      STATUS::SUBMITTED
    end
  end

  def draft?; status == STATUS::DRAFT; end
  def submitted?; status == STATUS::SUBMITTED; end
  def in_progress?; status == STATUS::IN_PROGRESS; end
  def completed?; status == STATUS::COMPLETED; end
end
