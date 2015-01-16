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
    @main_content_page = true
    @home_page = true
    @title = "Contests"
    @description = "See the ongoing, upcoming and past contests"
    @clarifications = clarifications
    upcoming_contests = Contest.where({ start_time: { :$gt => DateTime.now } })
    ongoing_contests = Contest.where({ start_time: { :$lte => DateTime.now }, end_time: { :$gte => DateTime.now } })
    past_contests = Contest.where({ end_time: { :$lt => DateTime.now } })
    @contests_array = []
    @contests_array << { data: upcoming_contests, name: "Upcoming Contests", panel_color: "info" }
    @contests_array << { data: ongoing_contests, name: "Ongoing Contests", panel_color: "success" }
    @contests_array << { data: past_contests, name: "Past Contests", panel_color: "danger" }
  end

  def clarifications
    return nil
  end

  def contests
    contest_code = params[:ccode]
    contest = Contest.where({ ccode: contest_code }).first
    redirect_to controller: 'error', action: 'error_404' if contest.nil?
    @main_content_page = true
    @contest_page = true
    @title = contest[:name]
    @description = "Problems and rules for " + @title
    problems = contest.problems.order_by({ submissions_count: -1 })
    @problems_hash = { data: problems, name: "Problems for " + contest[:name], panel_color: "purple", ccode: contest_code }
  end

end
