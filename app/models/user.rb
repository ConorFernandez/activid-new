class User < ActiveRecord::Base
  class ROLE
    USER = "user"
    EDITOR = "editor"
    ADMIN = "admin"
  end

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects

  validates_confirmation_of :password
end
