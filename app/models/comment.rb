class Comment < ActiveRecord::Base
  belongs_to :project
  belongs_to :poster, class_name: "User"
end
