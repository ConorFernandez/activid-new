class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :poster, class_name: "User"
end
