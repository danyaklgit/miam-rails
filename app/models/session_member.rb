class SessionMember < ApplicationRecord
  belongs_to :dining_session

  validates :user_id, presence: true
end
