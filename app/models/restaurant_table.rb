class RestaurantTable < ApplicationRecord
  belongs_to :restaurant
  has_many :dining_sessions, dependent: :destroy
  has_many :reservations, dependent: :nullify

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :number, uniqueness: { scope: :restaurant_id }
  validates :status, inclusion: { in: %w[available occupied] }

  scope :available, -> { where(status: "available") }
end
