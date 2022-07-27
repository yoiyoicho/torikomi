class UserLineUserRelationship < ApplicationRecord
  belongs_to :user
  belongs_to :line_user
end
