class Project < ActiveRecord::Base
  include Project::Status

  CATEGORIES = {
    vacation:    {name: "Vacation",    cost: 95},
    kickstarter: {name: "Kickstarter", cost: 195},
    sports:      {name: "Sports",      cost: 95},
    weddings:    {name: "Weddings",    cost: 329}
  }

  LENGTHS = {
    two_three:  {name: "2-3 minutes",   cost: 0},
    three_five: {name: "3-5 minutes",   cost: 0},
    five_ten:   {name: "5-10 minutes",  cost: 39},
    ten_twenty: {name: "10-20 minutes", cost: 79}
  }

  TURNAROUNDS = {
    seven_day: {name: "7-Day Turnaround", cost: 0,  time: 7.days},
    five_day:  {name: "5-Day Turnaround", cost: 20, time: 5.days},
    three_day: {name: "3-Day Turnaround", cost: 30, time: 3.days}
  }

  belongs_to :user
  belongs_to :editor, class_name: "User"
  belongs_to :payment_method

  has_many :file_uploads, as: :attachable
  has_many :comments
  has_many :cuts

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :uuid, :presence => true,
                   :uniqueness => true

  def needs_approval?
    # TEMPORARY
    false
  end

  def to_param
    uuid
  end

  def category_name
    CATEGORIES[category.try(:to_sym)].try(:[], :name)
  end

  def category_cost
    CATEGORIES[category.try(:to_sym)].try(:[], :cost) || 0
  end

  def desired_length_name
    LENGTHS[desired_length.try(:to_sym)].try(:[], :name)
  end

  def desired_length_cost
    LENGTHS[desired_length.try(:to_sym)].try(:[], :cost) || 0
  end

  def cut_due_at
    turnaround_time = TURNAROUNDS[turnaround.try(:to_sym)].try(:[], :time)

    return false unless turnaround_time && submitted_at && needs_cut?

    submitted_at + turnaround_time
  end

  def needs_cut?
    submitted? || in_progress?
  end

  def calculated_price
    costs = [
      category_cost,
      desired_length_cost,
      (watermark ? 0 : 5)
    ]

    costs.sum * 100
  end

  def submit!
    update(price: calculated_price, submitted_at: Time.now)
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
