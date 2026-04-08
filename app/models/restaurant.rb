class Restaurant < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :restaurant_tables, dependent: :destroy
  has_many :staff_members, dependent: :destroy
  has_many :dining_sessions, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :customer_addresses, dependent: :destroy
  has_many :reservations, dependent: :destroy

  validates :slug, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :name, presence: true, length: { maximum: 255 }
  validates :owner_id, presence: true
  validates :status, presence: true, inclusion: { in: %w[active disabled pending] }
end
