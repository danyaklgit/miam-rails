class Offer < ApplicationRecord
  include OfferCalculator

  self.inheritance_column = nil # disable STI — "type" is percentage/fixed/happyHour/bundle

  belongs_to :restaurant

  validates :type, presence: true, inclusion: { in: %w[percentage fixed happyHour bundle] }
  validates :name, presence: true, length: { maximum: 255 }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
