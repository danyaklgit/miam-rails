class Category < ApplicationRecord
  belongs_to :menu
  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }

  scope :sorted, -> { order(sort_order: :asc) }
end
