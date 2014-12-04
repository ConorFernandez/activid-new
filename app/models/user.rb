class User < ActiveRecord::Base
  include User::Role

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects
  has_many :assigned_projects, class_name: "Project", foreign_key: "editor_id"
  has_many :posted_comments, class_name: "Comment", foreign_key: "poster_id"

  validates_confirmation_of :password

  def can_view_project?(project)
    if user?
      # current users can only view their own projects and projects that don't belong to anyone
      project.user.nil? || project.user == self
    elsif editor?
      # editors can only view their assigned projects and submitted projects
      project.submitted? || project.editor == self
    elsif admin?
      # admins can view everything
      true
    else
      # how did we even get here?
      false
    end
  end
end
