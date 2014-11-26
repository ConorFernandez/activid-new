class PaymentMethod < ActiveRecord::Base
  has_many :projects

  validates :token, presence: true, uniqueness: true
end
