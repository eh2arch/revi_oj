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

  def contests
    @main_content_page = true
    @contest_page = true
    @title = "Contests"
    @description = "See the oncoming, upcoming and past contests"
    @clarifications = clarifications
    @upcoming_contests = Contest.where({ start_time: { :$gt => DateTime.now } })
    @ongoing_contests = Contest.where({ start_time: { :$lte => DateTime.now }, end_time: { :$gte => DateTime.now } })
    @past_contests = Contest.where({ end_time: { :$lt => DateTime.now } })
  end

  def clarifications
    return nil
  end

end
