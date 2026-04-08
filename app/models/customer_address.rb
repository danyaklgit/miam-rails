class CustomerAddress < ApplicationRecord
  belongs_to :restaurant, optional: true

  validates :user_id, presence: true
  validates :street, presence: true, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :postal_code, presence: true, length: { maximum: 20 }
end
