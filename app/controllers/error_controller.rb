class ErrorController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  def error_404
    @main_content_page = true
    @error_page = true
    @title = "Error"
    @description = "Page not found"
  end

end
