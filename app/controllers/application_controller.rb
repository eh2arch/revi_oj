Moped::BSON = BSON

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
    @contests_array << { data: ongoing_contests, name: "Ongoing Contests", panel_color: "success" }
    @contests_array << { data: upcoming_contests, name: "Upcoming Contests", panel_color: "info" }
    @contests_array << { data: past_contests, name: "Past Contests", panel_color: "danger" }
  end

  def clarifications
    return nil
  end

  def contests
    contest_code = params[:ccode]
    contest = Contest.where( ccode: contest_code, state: true, start_time: { :$lte => DateTime.now } ).first
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
    @contest_code = params[:ccode]
    @problem_code = params[:pcode]
    contest = Contest.where({ ccode: @contest_code, state: true, start_time: { :$lte => DateTime.now } }).first
    if contest.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    problem = contest.problems.where({ pcode: @problem_code, state: true }).first
    if problem.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    @main_content_page = true
    @problem_page = true
    @title = problem[:name]
    @problem_text = problem[:statement]
    @language_names = get_language_parameter(problem, 'name')
    @language_langcodes = get_language_parameter(problem, 'langcode')
    @creator_name = problem.creator.user[:full_name]
    @creator_username = problem.creator.user[:username]
    @problem_created_at = problem[:created_at]
    link = view_context.link_to(@creator_name, { action: 'users', username: @creator_username }, class: "text-info")
    @description = 'Created <span class="timeago text-primary" title="' + problem[:created_at].to_time.iso8601.to_s + '"></span> by ' + link
    @description = @description.html_safe
  end

  def verify_submission
    user_source_code = params["user_source_code"]
    language = params["language"]
    problem_code = params["pcode"]
    contest_code = params["ccode"]
    language_document = Language.where(name: language).first
    if language_document.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    contest = Contest.where({ ccode: contest_code, state: true }).first
    if contest.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    problem = contest.problems.where({ pcode: problem_code, state: true }).first
    if problem.nil? || contest[:start_time] > DateTime.now || contest[:end_time] < DateTime.now
      redirect_to controller: 'error', action: 'error_404' and return
    end
    latest_submission = current_user.submissions.order_by({ created_at: -1 }).first
    unless latest_submission.nil?
      if DateTime.now.to_time - latest_submission[:created_at] < 30
        @notif_quick_submit = true
        home and render action: 'home'
        return
      end
    end
    source_limit = problem[:source_limit]
    if user_source_code.length > source_limit
        @notif_source_limit_exceed = true
        home and render action: 'home'
        return
    end
    submission = Submission.new(user_source_code: user_source_code, submission_time: DateTime.now)
    submission.language = language_document
    problem.submissions << submission
    current_user.submissions << submission
    submission.save_submission
    if contest.users.where(email: current_user[:email]).count == 0
      contest.users << current_user
    end

    # Put worker in queue
    ProcessSubmission.perform_async({ submission_id: submission[:_id].to_s })

    @notif_submission_success = true
    home and render action: 'home'
    return
  end

  def scoreboard
    @main_content_page = true
    @scoreboard_page = true
    @title = params[:ccode]
    @contest_code = params[:ccode]
    contest = Contest.where({ ccode: @contest_code, state: true, start_time: { :$lte => DateTime.now } }).first
    if contest.nil?
      redirect_to controller: 'error', action: 'error_404' and return
    end
    @contest_start_time = contest[:start_time]

    # Submission.collection.aggregate([ { "$match" => { "status_code" => "AC" } }, { "$group" => { "_id" => "$user_id", "ac_count"=> { "$sum" => 1 }}},{ "$sort"=> {"acs"=> -1} }])

    contest_users = contest.users
    @user_array = []
    @current_user_arr = {}
    @problems = contest.problems.only(:_id, :pcode, :name)
    contest_users.each do |user|
      user_hash = { email: user[:email], college: user[:college], username: user[:username] }
      problem_array = []
      total_time = @contest_start_time
      total_success = 0
      @problems.each do |problem|
        problem_hash = { pcode: problem[:pcode], name: problem[:name] }
        problem_submissions = Submission.where(user_id: user[:_id], problem_id: problem[:_id])
        problem_submissions_ac = problem_submissions.where(status_code: "AC").order_by(submission_time: 1)
        if problem_submissions_ac.count > 0
          user_ac_earliest_time = problem_submissions_ac.first[:submission_time]
          problem_hash.merge! ({ success_time: user_ac_earliest_time, success: true })
          user_not_ac_count = problem_submissions
                              .where(:status_code.nin => ["AC", "PE", "CE"], :submission_time.lte => user_ac_earliest_time)
                              .count
          problem_hash.merge! ({ wa_count: user_not_ac_count })
          total_time += user_ac_earliest_time - @contest_start_time + user_not_ac_count * CONFIG[:penalty].minutes
          total_success += 1
        else
          problem_hash.merge! ({ success: false })
          user_wa_count = problem_submissions
                              .where(:status_code.nin => ["AC", "PE", "CE"])
                              .count
          problem_hash.merge! ({ wa_count: user_wa_count })
        end
        problem_array << problem_hash
      end
      user_hash.merge! ({ problems: problem_array, total_time: (total_time - @contest_start_time) / 60, successes: total_success })
      if current_user[:email] == user[:email]
        @current_user_arr = user_hash
      end
      @user_array << user_hash
    end
    puts @current_user_arr[:email].to_s
    @user_array.sort! { |a,b| a[:successes] > b[:successes] ? -1 : (a[:successes] < b[:successes] ? 1 : (a[:total_time] <=> b[:total_time])) }
  end

end
