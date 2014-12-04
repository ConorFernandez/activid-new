class Cut < ActiveRecord::Base
  belongs_to :project
  belongs_to :uploader, class_name: "User"

  has_many :file_uploads, as: :attachable
end
