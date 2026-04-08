class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_default_format

  private

  def set_default_format
    request.format = :json
  end

  def device_id
    session[:device_id] ||= SecureRandom.uuid
  end
end
