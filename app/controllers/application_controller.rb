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
    contest = Contest.where({ ccode: contest_code, state: true }).first
    if contest.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    @main_content_page = true
    @contest_page = true
    @title = contest[:name]
    @description = "Problems and rules for " + @title
    problems = contest.problems.where({ state: true }).order_by({ submissions_count: -1 })
    language_array = []
    problems.each { |problem| language_array << get_language_parameter(problem, 'name') }
    @problems_hash = { data: problems, name: "Problems for " + contest[:name], panel_color: "purple", ccode: contest_code, langdata: language_array }
  end

  def get_language_parameter(collection ,parameter)
    collection.languages.to_a.map { |language| language[parameter.to_sym] }
  end

  def problem
    contest_code = params[:ccode]
    problem_code = params[:pcode]
    contest = Contest.where({ ccode: contest_code, state: true }).first
    if contest.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    problem = contest.problems.where({ pcode: problem_code, state: true }).first
    if problem.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    @main_content_page = true
    @problem_page = true
    @title = problem[:name]
    @problem_text = problem[:statement]
    @language_names = get_language_parameter(problem, 'name')
    @language_langcodes = get_language_parameter(problem, 'langcode')
    @creator_name = problem.creators.first.user[:full_name]
    @creator_username = problem.creators.first.user[:username]
    @problem_created_at = problem[:created_at]
    link = view_context.link_to(@creator_name, { action: 'users', username: @creator_username }, class: "text-info")
    @description = 'Created <span class="timeago text-primary" title="' + problem[:created_at].to_time.iso8601.to_s + '"></span> by ' + link
    @description = @description.html_safe
  end

  def users
  end

end
