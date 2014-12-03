class User < ActiveRecord::Base
  include User::Role

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects

  validates_confirmation_of :password
end
