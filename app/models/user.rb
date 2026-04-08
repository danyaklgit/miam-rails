class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :role, presence: true, inclusion: {
    in: %w[customer owner manager waiter finance kitchen bar super_admin]
  }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def super_admin?
    role == "super_admin" || email.in?(super_admin_emails)
  end

  def owner?
    role == "owner"
  end

  def staff?
    role.in?(%w[manager waiter finance kitchen bar])
  end

  private

  def super_admin_emails
    ENV.fetch("SUPER_ADMIN_EMAILS", "").split(",").map(&:strip)
  end
end
