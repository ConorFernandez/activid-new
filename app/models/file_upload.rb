class FileUpload < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true

  validates :url, uniqueness: true
end
