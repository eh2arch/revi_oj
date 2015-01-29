class ProcessSubmission

  include Process
  include Sidekiq::Worker
  sidekiq_options unique: true, :queue => :default, :retry => 5
  require 'scanf'

Docker::API_VERSION = '1.11.2'

  def perform(args)
  	file_extensions = { 'c++' => '.cpp', 'java' => '.java', 'python' => '.py', 'c' => '.cc' }
  	submission_id = args["submission_id"]
  	submission = get_submission(submission_id)
  	if submission.nil?
  		return
  	end
  	langcode = submission.language[:langcode]
  	user_email = submission.user[:email]
  	problem = submission.problem
  	pcode = problem[:pcode]
  	ccode = problem.contest[:ccode]
  	tlimit = problem[:time_limit] * submission.language[:time_multiplier]
  	mlimit = problem[:memory_limit]
  	@submission_path = "#{CONFIG[:base_path]}/#{user_email}/#{ccode}/#{pcode}/#{submission_id}/"

  	if langcode == 'c++'
  		compile_path = "bash -c 'g++ -std=c++0x -w -O2 -fomit-frame-pointer -lm -o ./compiled_code ./user_source_code#{file_extensions[langcode]} >& ./compiler'"
    elsif langcode == 'c'
      compile_path = "bash -c 'gcc -std=gnu99 -w -O2 -fomit-frame-pointer -lm -o ./compiled_code ./user_source_code#{file_extensions[langcode]} >& ./compiler'"
    elsif langcode == 'java'
      compile_path = "bash -c 'javac ./Main#{file_extensions[langcode]} >& ./compiler'"
    elsif langcode == 'python'
      compile_path = "bash -c 'python -m py_compile ./user_source_code#{file_extensions[langcode]} >& ./compiler'"
    end
    pid = spawn(compile_path, :chdir => @submission_path)
    pid, status = wait2(pid, 0)
    if !status.exited? || status.exitstatus.to_i != 0
      compilation_error = nil
      begin
        compilation_error = File.read(@submission_path + "compiler")
      rescue
        compilation_error = "Unknown error"
      end
      submission.update_attributes!(status_code: "CE", error_description: compilation_error)
      return
    end

  	signal_list = Signal.list.invert

  	test_cases = problem.test_cases
  	@test_case_path = "#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_cases/"
  	@test_case_output_path = "#{CONFIG[:base_path]}/contests/#{ccode}/#{pcode}/test_case_outputs/"

  	total_running_time = 0

  	test_cases.each do |test_case|
  		time_start = Time.now()
      if langcode == 'python'
        pid = spawn({"SHELL" => "/bin/bash"}, "python #{@submission_path}user_source_code#{file_extensions[langcode]}", :rlimit_rss => [mlimit,mlimit], :rlimit_stack => [mlimit,mlimit], :rlimit_cpu => [tlimit + 1,tlimit + 1], :rlimit_fsize => [50000000,50000000], :out => "#{@submission_path}#{test_case[:name]}", :in => "#{@test_case_path}#{test_case[:name]}")
      elsif langcode == 'java'
          pid = spawn({"SHELL" => "/bin/bash"}, "java -cp #{@submission_path} Main", :rlimit_rss => [1572864000,1572864000], :rlimit_stack => [1572864000,1572864000], :rlimit_cpu => [tlimit + 1,tlimit + 1], :rlimit_fsize => [50000000,50000000], :out => "#{@submission_path}#{test_case[:name]}", :in => "#{@test_case_path}#{test_case[:name]}")
      else
    		pid = spawn({"SHELL" => "/bin/bash"}, "#{@submission_path}compiled_code", :rlimit_rss => [mlimit,mlimit], :rlimit_stack => [mlimit,mlimit], :rlimit_cpu => [tlimit + 1,tlimit + 1], :rlimit_fsize => [50000000,50000000], :out => "#{@submission_path}#{test_case[:name]}", :in => "#{@test_case_path}#{test_case[:name]}")
      end
  		pid_new = status = max_memory_used = 0
  		error_flag = nil

  		loop do
	  		begin
		  		pid_new, status = wait2(pid, Process::WNOHANG)
		  		if status.nil? || pid_new.nil?
		  			memory_used = get_memory_usage(pid)
		  			max_memory_used = [max_memory_used, memory_used].max
		  			if max_memory_used > mlimit
		  				error_flag = 'MLE'
		  			elsif Time.now() - time_start > tlimit
		  				error_flag = 'TLE'
		  			end
		  		else
		  			if status.exited? && status.exitstatus.to_i != 0
		  				if signal_list.has_key?(status.exitstatus.to_i)
		  					error_flag = signal_list[status.exitstatus.to_i]
		  				else
		  					error_flag = 'RTE'
		  				end
		  			elsif status.exited? && status.exitstatus.to_i == 0
		  				break
		  			end
		  		end
	  			unless error_flag.nil?
            begin
  	  				Process.kill('KILL', pid)
  	  				break
            rescue Errno::ESRCH => e
              break
            end
	  			end
		  	rescue Errno::ECHILD => e
		  	end
		  end
		  if error_flag.nil?
			  running_time = Time.now() - time_start
			  total_running_time += running_time
			else
		  	submission = get_submission(submission_id)
		  	if submission.nil?
		  		return
		  	end
				submission.update_attributes!( status_code: error_flag, error_description: error_flag )
				return
			end

	  	unless test_case[:checker_is_a_code]
		  	submission = get_submission(submission_id)
		  	if submission.nil?
		  		return
		  	end
	  		if !check_solution(test_case)
	  			submission.update_attributes!( status_code: "WA", error_description: "WA" )
	  		end
	  	end

  	end

  	submission = get_submission(submission_id)
  	if submission.nil?
  		return
  	end
  	submission.update_attributes!( status_code: 'AC', running_time: total_running_time )

  end

  def get_memory_usage(pid)
  	proc_path = "/proc/#{pid}/status"
  	file_read = File.read(proc_path)
  	data = stack = 0
  	file_read.each_line do |line|
	  	vmDataInd = line.index("VmData:")
	  	vmStkInd = line.index("VmStk:")
	  	unless vmDataInd.nil?
	  		data = line.scanf("VmData%*s %d")[0]
	  	end
	  	unless vmStkInd.nil?
	  		stack = line.scanf("VmStk%*s %d")[0]
	  	end
		end
		return data + stack
  end

  def check_solution(test_case)
  	user_solution_path = @submission_path + test_case[:name]
  	test_case_solution_path = @test_case_output_path + test_case[:name]
  	begin
	  	user_solution = File.read(user_solution_path)
	  	test_case_solution = File.read(test_case_solution_path)
  	rescue
  		return false
  	end
  	test_case_solution.lines.each_with_index do |test_line, index|
  		test_token_array = test_line.strip.split()
  		begin
  			user_token_array = user_solution.lines[index].strip.split()
  		rescue
  			return false
  		end
  		if test_token_array != user_token_array
  			return false
  		end
  	end

  	return true
  end

  def get_submission(submission_id)
  	submission = Submission.where(_id: submission_id.to_s).first
  	if submission.nil? || submission[:status_code] != "PE"
  		return nil
  	end
  	return submission
  end

end