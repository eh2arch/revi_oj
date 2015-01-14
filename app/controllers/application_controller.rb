Moped::BSON = BSON

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # require 'rubygems'
  # require 'twitter'
  # require 'json'
  # require 'net/https'
  # require 'open-uri'
  # require 'bson'
  # require 'active_support/inflector'

  before_filter :authenticate_user!

  def home
  end

end
