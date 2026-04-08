module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user_id
    end

    private

    def find_verified_user_id
      # Allow both authenticated users and anonymous sessions (dine-in customers)
      if env["warden"].user
        env["warden"].user.id
      elsif cookies.signed[:device_id]
        cookies.signed[:device_id]
      else
        SecureRandom.uuid.tap { |id| cookies.signed[:device_id] = id }
      end
    end
  end
end
