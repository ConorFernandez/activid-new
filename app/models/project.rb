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

  REMOVE_LOGO_COST = 2500
  ADDITIONAL_CUT_COST = 2500
  STRIPE_CHARGE_PERCENTAGE = 0.029
  STRIPE_CHARGE_FLAT = 30

  belongs_to :user
  belongs_to :editor, class_name: "User"

  has_many :file_uploads, as: :attachable
  has_many :comments, as: :commentable
  has_many :cuts

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  serialize :activid_music_urls, Array

  validates :uuid, :presence => true,
                   :uniqueness => true

  def needs_approval?
    latest_cut.try(:needs_approval?)
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
      turnaround_time_cost,
      cost_of_additional_cuts
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

  def cost_of_additional_cuts
    if rejected_cuts.any?
      (rejected_cuts.count - 1) * ADDITIONAL_CUT_COST
    else
      0
    end
  end

  def display_price
    (charged_price.present? && charged_price != 0) ? charged_price : calculated_price
  end

  def submit!
    update(initial_price: calculated_price, submitted_at: Time.now)
    Mailer.new_project_created(self).deliver
  end

  def submittable?
    purchasable? && user.present? && user.stripe_customer_id.present? && stripe_card_id.present?
  end

  def processed_cuts
    cuts.order("created_at ASC").select(&:processed?)
  end

  def rejected_cuts
    cuts.select(&:rejected?)
  end

  def first_cut
    processed_cuts.first
  end

  def latest_cut
    processed_cuts.last
  end

  def purchasable?
    user.present? && draft? && video_uploads.any? && all_uploads_encoded?
  end

  def duration_of_uploads # in seconds
    all_uploads_encoded? ? video_uploads.map(&:duration).sum : nil
  end

  def all_uploads_encoded?
    video_uploads.all?(&:zencoder_finished?)
  end

  def has_failed_uploads?
    video_uploads.any?(&:zencoder_failed?)
  end

  def editor_earnings
    if charged_price.present? && charged_price != 0
      (((charged_price * (1 - STRIPE_CHARGE_PERCENTAGE)) - STRIPE_CHARGE_FLAT) * 0.7).to_i
    else
      ((((calculated_price.presence || 0) * (1 - STRIPE_CHARGE_PERCENTAGE)) - STRIPE_CHARGE_FLAT) * 0.7).to_i
    end
  end

  def stripe_earnings
    if charged_price.present? && charged_price != 0
      ((charged_price * STRIPE_CHARGE_PERCENTAGE) + STRIPE_CHARGE_FLAT).to_i
    else
      (((calculated_price.presence || 0) * STRIPE_CHARGE_PERCENTAGE) + STRIPE_CHARGE_FLAT).to_i
    end
  end

  def video_uploads
    file_uploads.select(&:video?)
  end

  def music_uploads
    file_uploads.select(&:music?)
  end

  def image_uploads
    file_uploads.select(&:image?)
  end

  def charge!
    if charged_at.nil?
      Stripe::Charge.create(
        amount: calculated_price,
        currency: "usd",
        customer: user.stripe_customer_id,
        card: stripe_card_id,
        description: "#{user.email}: \"#{name}\""
      )

      update(charged_at: Time.now, charged_price: calculated_price)
    else
      return false
    end
  rescue Stripe::CardError => e
    Rails.logger.error "Error charging project #{id}: #{e}"
    return false
  end

  def pay_editor!
    if attempted_to_pay_editor_at.nil?
      Stripe::Transfer.create(
        amount: editor_earnings,
        currency: "usd",
        recipient: editor.stripe_recipient_id,
        description: "Payment to #{editor.email} for #{user.email}'s project \"#{name}\""
      )
    else
      return false
    end
  end

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
