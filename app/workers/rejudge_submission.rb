class RejudgeSubmission
  include Sidekiq::Worker

  sidekiq_options retry: 5
  sidekiq_options :failures => true

  def perform(args)
  	unless args.nil?
  		args.each do |submission_id|
		    submission = Submission.where(_id: submission_id).first
		    unless submission.nil?
		    	submission.update_attributes!( status_code: "PE" )
	  			ProcessSubmission.perform_async({ submission_id: submission_id.to_s })
	  		end
  		end
  	end
  end

end