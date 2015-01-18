namespace :reset do
	desc "Reset submissions counters"
  	task :all_submission_counters => :environment do
  		Problem.each { |u| Problem.reset_counters(u.id, :submissions) }
  		User.each { |u| User.reset_counters(u.id, :submissions) }
  	end
	desc "Reset problems counters"
  	task :all_problem_counters => :environment do
  		Contest.each { |u| Contest.reset_counters(u.id, :problems) }
  	end
end