class Cut < ActiveRecord::Base
  belongs_to :project
  belongs_to :uploader, class: "User"

  has_many :file_uploads, as: :attachable
end
