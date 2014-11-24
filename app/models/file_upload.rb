class FileUpload < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  before_validation :generate_uuid, :on => :create,
                                    :if => Proc.new { |p| p.uuid.blank? }

  validates :url, uniqueness: true
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
