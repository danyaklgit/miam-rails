class Reservation < ApplicationRecord
  belongs_to :restaurant
  belongs_to :restaurant_table, optional: true

  validates :date, presence: true
  validates :time, presence: true
  validates :party_size, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :customer_name, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[pending confirmed seated completed cancelled noShow] }

  scope :upcoming, -> { where("date >= ?", Date.current.to_s) }
  scope :by_status, ->(status) { where(status: status) }
end
