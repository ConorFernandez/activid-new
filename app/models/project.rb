class Project < ActiveRecord::Base
  CATEGORIES = {
    vacation:    {name: "Vacation", starting_price: 95},
    kickstarter: {name: "Kickstarter", starting_price: 195},
    sports:      {name: "Sports", starting_price: 95},
    weddings:    {name: "Weddings", starting_price: 329}
  }

  LENGTHS = {
    two_three:  {name: "2-3 minutes"},
    three_five: {name: "3-5 minutes"},
    five_ten:   {name: "5-10 minutes", additional_price: 39},
    ten_twenty: {name: "10-20 minutes", additional_price: 79}
  }

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :uuid, :presence => true,
                   :uniqueness => true


  def to_param
    uuid
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
