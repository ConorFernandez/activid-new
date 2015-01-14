class User < ActiveRecord::Base
  include User::Role

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :projects
  has_many :comments, as: :commentable
  has_many :assigned_projects, class_name: "Project", foreign_key: "editor_id"
  has_many :posted_comments, class_name: "Comment", foreign_key: "poster_id"
  has_many :uploaded_cuts, class_name: "Cut", foreign_key: "uploader_id"

  validates_confirmation_of :password

  scope :editor, -> { where(role: ROLE::EDITOR) }

  def can_view_project?(project)
    if user?
      # current users can only view their own projects and projects that don't belong to anyone
      project.user.nil? || project.user == self
    elsif editor?
      # editors can only view their assigned projects and available projects
      project.available? || project.editor == self
    elsif admin?
      # admins can view everything
      true
    else
      # how did we even get here?
      false
    end
  end

  def can_view_cut?(cut)
    if user?
      cut.processed? && cut.project.user == self
    elsif editor?
      cut.project.editor == self
    elsif admin?
      true
    end
  end

  def has_bank_account?
    stripe_recipient_id.present? && bank_account_last_four.present?
  end

  def stripe_customer
    stripe_customer_id.present? ? Stripe::Customer.retrieve(stripe_customer_id) : nil
  end

  def total_earnings
    assigned_projects.select(&:completed?).sum{|p| p.editor_earnings}
  end
end
