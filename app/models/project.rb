class Project < ActiveRecord::Base
  CATEGORIES = {
    vacation:    {name: "Vacation", cost: 95},
    kickstarter: {name: "Kickstarter", cost: 195},
    sports:      {name: "Sports", cost: 95},
    weddings:    {name: "Weddings", cost: 329}
  }

  LENGTHS = {
    two_three:  {name: "2-3 minutes", cost: 0},
    three_five: {name: "3-5 minutes", cost: 0},
    five_ten:   {name: "5-10 minutes", cost: 39},
    ten_twenty: {name: "10-20 minutes", cost: 79}
  }

  TURNAROUNDS = {
    seven_day: {name: "7-Day Turnaround", cost: 0},
    five_day:  {name: "5-Day Turnaround", cost: 20},
    three_day: {name: "3-Day Turnaround", cost: 30}
  }

  belongs_to :user
  belongs_to :payment_method

  has_many :file_uploads, as: :attachable

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :uuid, :presence => true,
                   :uniqueness => true


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

  def status
    if price.nil?
      :draft
    else
      :submitted
    end
  end

  def calculated_price
    costs = [
      category_cost,
      desired_length_cost,
      (watermark ? 0 : 5)
    ]

    costs.sum * 100
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
