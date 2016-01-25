class Problem
  include Mongoid::Document
  include Mongoid::Timestamps::Created::Short

  field :name,                   type: String, default: ''
  field :pcode,                  type: String, default: ''
  field :state, 				 type: Boolean, default: true
  field :statement,				 type: String, default: ''
  field :time_limit,			 type: Float, default: '1.0'
  field :memory_limit,			 type: Integer, default: 268435456
  field :source_limit,			 type: Integer, default: 51200
  field :submissions_count,		 type: Integer, default: 0

  belongs_to :creator, :counter_cache => true

  belongs_to :contest, :counter_cache => true

  has_many :submissions, :dependent => :destroy
  has_and_belongs_to_many :languages

  has_many :test_cases, :dependent => :destroy

  before_save :create_problem_folder
  before_destroy :destroy_problem_folder

  private
    def create_problem_folder
    	contest = self.contest
    	ccode = contest[:ccode]
    	users = contest.users
    	users.each do |user|
  	    email = user[:email]
  	    system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{self[:pcode]}"
    	end
    	system 'mkdir', '-p', "#{CONFIG[:base_path]}/contests/#{ccode}/#{self[:pcode]}/test_cases"
    	system 'mkdir', '-p', "#{CONFIG[:base_path]}/contests/#{ccode}/#{self[:pcode]}/test_case_outputs"
      return true
    end

    def destroy_problem_folder
      contest = self.contest
      ccode = contest[:ccode]
      users = contest.users
      users.each do |user|
        email = user[:email]
        system 'rm', '-rf', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{self[:pcode]}"
      end
      system 'rm', '-rf', "#{CONFIG[:base_path]}/contests/#{ccode}/#{self[:pcode]}"
      return true
    end

end
