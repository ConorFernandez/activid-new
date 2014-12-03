class User < ActiveRecord::Base
  include User::Role

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects
  has_many :assigned_projects, class_name: "Project", foreign_key: "editor_id"

  validates_confirmation_of :password
end
