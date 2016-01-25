class TestCase
  include Mongoid::Document
  include Mongoid::Paperclip

  field :name,                   type: String, default: ''
  field :checker_is_a_code,		 type: Boolean, default: false

  belongs_to :problem, :counter_cache => true

  has_mongoid_attached_file :test_case
  has_mongoid_attached_file :test_case_output
  do_not_validate_attachment_file_type :test_case
  do_not_validate_attachment_file_type :test_case_output
  # validates_attachment_content_type :test_case, content_type: { content_type: "text/plain" }
  # validates_attachment_content_type :test_case_output, presence: true, content_type: { content_type: "text/plain" }

  before_save :create_test_case
  before_destroy :delete_test_case

  private
    def create_test_case
      problem = self.problem
      contest = problem.contest
      ccode = contest[:ccode]
      pcode = problem[:pcode]
      test_case = File.open("#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_cases/#{self[:name]}", 'w')
      test_case.write(Paperclip.io_adapters.for(self.test_case).read)
      test_case.close
      test_case_output = File.open("#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_case_outputs/#{self[:name]}", 'w')
      test_case_output.write(Paperclip.io_adapters.for(self.test_case_output).read)
      test_case_output.close
      self[:test_case] = ""
      self[:test_case_output] = ""
      return true
    end

    def delete_test_case
      problem = self.problem
      contest = problem.contest
      ccode = contest[:ccode]
      pcode = problem[:pcode]
      system 'rm', '-rf', "#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_cases/#{self[:name]}"
      system 'rm', '-rf', "#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_case_outputs/#{self[:name]}"
      return true
    end
end
