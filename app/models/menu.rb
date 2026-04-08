class Menu < ApplicationRecord
  belongs_to :restaurant
  has_many :categories, dependent: :destroy
  has_many :menu_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }

  scope :active, -> { where(is_active: true) }
  scope :sorted, -> { order(sort_order: :asc) }
end
