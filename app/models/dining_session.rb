class DiningSession < ApplicationRecord
  belongs_to :restaurant
  belongs_to :restaurant_table
  has_many :session_members, dependent: :destroy
  has_one :order, class_name: "Order", foreign_key: :session_id, primary_key: :id

  validates :status, inclusion: { in: %w[active closed] }

  scope :active, -> { where(status: "active") }

  after_commit :broadcast_member_update, on: [:update]

  private

  def broadcast_member_update
    Turbo::StreamsChannel.broadcast_replace_to(
      "session_#{id}",
      target: "session_members",
      partial: "customer/tables/session_members",
      locals: { members: session_members.reload }
    )
  rescue ActionView::MissingTemplate
    # Partial not yet created — skip broadcast
  end
end
