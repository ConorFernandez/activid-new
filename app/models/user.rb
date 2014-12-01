class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects

  validates_confirmation_of :password

  def role
    :user
  end
end
