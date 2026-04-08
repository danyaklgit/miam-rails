class StaffMember < ApplicationRecord
  belongs_to :restaurant

  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, length: { maximum: 255 }
  validates :role, presence: true, inclusion: { in: %w[manager waiter finance] }
end
