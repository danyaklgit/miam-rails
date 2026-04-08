class MenuItem < ApplicationRecord
  self.inheritance_column = nil # disable STI — "type" is food/drink, not a subclass

  belongs_to :category
  belongs_to :menu
  belongs_to :restaurant

  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true, inclusion: { in: %w[food drink] }

  scope :available, -> { where(available: true) }
  scope :sorted, -> { order(sort_order: :asc) }
  scope :food, -> { where(type: "food") }
  scope :drinks, -> { where(type: "drink") }
end
