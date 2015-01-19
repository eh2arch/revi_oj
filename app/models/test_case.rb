class TestCase
  include Mongoid::Document

  field :name,                   type: String, default: ''
  field :test_case,				 type: String, default: ''
  field :test_case_output,		 type: String, default: ''

  belongs_to :problem, :counter_cache => true

  before_save :create_test_case

  def create_test_case
  	problem = self.problem
  	contest = problem.contest
  	ccode = contest[:ccode]
  	pcode = contest[:pcode]
    system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/test_cases/#{self[:name]}"
    system 'mkdir', '-p', "#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/test_case_outputs/#{self[:name]}"
    test_case = File.open("#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/test_cases/#{self[:name]}", 'w')
	test_case.write(self[:test_case])
	test_case.close
	test_case_output = File.open("#{CONFIG[:base_path]}/#{email}/#{ccode}/#{pcode}/test_case_outputs/#{self[:name]}", 'w')
	test_case_output.write(self[:test_case_output])
	test_case_output.close
    return true
  end
end
