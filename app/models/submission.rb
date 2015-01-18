class Submission
  include Mongoid::Document

  field :submission_time,        type: DateTime, default: DateTime.now
  field :user_source_code,		 type: String, default: ''
  field :status_code,			 type: String, default: 'PE'
  field :running_time,			 type: Float
  # Status Codes:
  # AC - Accepted
  # WA - Wrong Answer
  # RTE - Run Time Error
  # TLE - Time Limit Exceeded
  # CE - Compilation Error
  # PE - Pending Execution
  has_one :language
  belongs_to :user, :counter_cache => true
  belongs_to :problem, :counter_cache => true

end
