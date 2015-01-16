namespace :reset do
	desc "Reset submissions counters"
  	task :all_submission_counters => :environment do
  		Problem.each { |u| Problem.reset_counters(u.id, :submissions) }
  		User.each { |u| User.reset_counters(u.id, :submissions) }
  	end
end