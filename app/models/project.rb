class Project < ActiveRecord::Base
  include Project::Status

  CATEGORIES = {
    vacation:    {name: "Travel / Vacation",       cost: 14500},
    family:      {name: "Family",                  cost: 14500},
    sports:      {name: "Sports",                  cost: 14500},
    drone:       {name: "Drone",                   cost: 14500},
    interview:   {name: "Interview",               cost: 29500},
    kickstarter: {name: "Kickstarter / Indiegogo", cost: 39500},
    wedding:     {name: "Wedding",                 cost: 39500},
    commercial:  {name: "Commercial",              cost: 49500},
    business:    {name: "Business",                cost: 49500}
  }

  LENGTHS = {
    one_three:    {name: "1-3 minutes",   cost: 0},
    three_five:   {name: "3-5 minutes",   cost: 0},
    five_ten:     {name: "5-10 minutes",  cost: 3900},
    ten_twenty:   {name: "10-20 minutes", cost: 8900},
    twenty_sixty: {name: "20-60 minutes", cost: 13900},
    sixty_plus:   {name: "60+ minutes",   cost: 19900}
  }

  TURNAROUNDS = {
    seven_day: {name: "7-Day Turnaround", cost: 0,    time: 7.days},
    five_day:  {name: "5-Day Turnaround", cost: 2900, time: 5.days},
    three_day: {name: "3-Day Turnaround", cost: 5900, time: 3.days},
    two_day:   {name: "2-Day Turnaround", cost: 7900, time: 3.days},
    one_day:   {name: "1-Day Turnaround", cost: 9900, time: 3.days}
  }

  REMOVE_LOGO_COST = 2900

  belongs_to :user
  belongs_to :editor, class_name: "User"
  belongs_to :payment_method

  has_many :file_uploads, as: :attachable
  has_many :comments, as: :commentable
  has_many :cuts

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  serialize :activid_music_urls, Array

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

  def turnaround_time_cost
    TURNAROUNDS[turnaround.try(:to_sym)].try(:[], :cost) || 0
  end

  def uploaded_footage_cost
    return 0 unless all_uploads_encoded?

    case duration_of_uploads
    when 0..(30*60)
      0
    when (30*60+1)..(60*60)
      3900
    when (60*60+1)..(120*60)
      8900
    when (120*60+1)..(180*60)
      13900
    else
      19900
    end
  end

  def remove_logo_cost
    append_logo ? 0 : REMOVE_LOGO_COST
  end

  def cut_due_at
    turnaround_time = TURNAROUNDS[turnaround.try(:to_sym)].try(:[], :time)

    return false unless turnaround_time && submitted_at

    submitted_at + turnaround_time
  end

  def needs_cut?
    (available? || in_progress?) && processed_cuts.empty?
  end

  def calculated_price # in pennies
    [
      category_cost,
      desired_length_cost,
      remove_logo_cost,
      uploaded_footage_cost,
      turnaround_time_cost
    ].sum
  end

  # for use on checkout page; price minus options that can be selected at checkout
  def base_price
    [
      category_cost,
      desired_length_cost,
      uploaded_footage_cost
    ].sum
  end

  def submit!
    update(price: calculated_price, submitted_at: Time.now)
  end

  def submittable?
    purchasable? && user.present? && payment_method.present?
  end

  def processed_cuts
    cuts.order("created_at ASC").select(&:processed?)
  end

  def first_cut
    processed_cuts.first
  end

  def purchasable?
    draft? && video_uploads.any? && all_uploads_encoded?
  end

  def duration_of_uploads # in seconds
    all_uploads_encoded? ? video_uploads.sum(:duration) : nil
  end

  def all_uploads_encoded?
    video_uploads.all?(&:zencoder_finished?)
  end

  def editor_earnings
    ((price.presence || 0) * 0.7).to_i
  end

  def video_uploads
    file_uploads.select(&:video?)
  end

  def music_uploads
    file_uploads.select(&:music?)
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
