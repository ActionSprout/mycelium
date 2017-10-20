class ApplicationController < ActionController::API
  def status
    render json: { status: 'online' }
  end
end
