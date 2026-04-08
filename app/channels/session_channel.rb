class SessionChannel < ApplicationCable::Channel
  def subscribed
    session = DiningSession.find(params[:id])
    stream_for session
  end
end
