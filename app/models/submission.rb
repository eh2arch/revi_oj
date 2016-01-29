class Submission
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :submission_time,        type: DateTime, default: DateTime.now
  field :user_source_code,		 type: String, default: ''
  field :status_code,			 type: String, default: 'PE'
  field :error_description,		 type: String
  field :running_time,			 type: Float
  # Status Codes:
  # AC - Accepted
  # WA - Wrong Answer
  # RTE - Run Time Error
  # TLE - Time Limit Exceeded
  # MLE - Memory Limit Exceeded
  # CE - Compilation Error
  # PE - Pending Execution
  belongs_to :language, :counter_cache => true
  belongs_to :user, :counter_cache => true
  belongs_to :problem, :counter_cache => true

  # before_save :save_submission
  # before_destroy :delete_submission

  def save_submission
  	file_extensions = { 'c++' => '.cpp', 'java' => '.java', 'python' => '.py', 'c' => '.cc' }
  	submission_id = self[:_id]
  	user = self.user
  	email = user[:email]
  	problem = self.problem
  	pcode = problem[:pcode]
  	contest = problem.contest
  	ccode = contest[:ccode]
  	language = self.language
  	langcode = language[:langcode]
  	system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/#{submission_id}"
    if langcode == 'java'
        input = File.open("#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/#{submission_id}/Main#{file_extensions[langcode]}", 'w')
    else
    	input = File.open("#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/#{submission_id}/user_source_code#{file_extensions[langcode]}", 'w')
    end
  	input.write(self[:user_source_code])
  	input.close
    problem.test_cases.each do |test_case|
      system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/#{submission_id}/#{test_case[:name]}"
    end
  	return true
  end

  def delete_submission
    file_extensions = { 'c++' => '.cpp', 'java' => '.java', 'python' => '.py', 'c' => '.cc' }
    submission_id = self[:_id]
    user = self.user
    email = user[:email]
    problem = self.problem
    pcode = problem[:pcode]
    contest = problem.contest
    ccode = contest[:ccode]
    language = self.language
    langcode = language[:langcode]
    system 'rm', '-rf', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/#{submission_id}"
    return true
  end
end
