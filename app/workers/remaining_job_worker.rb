class RemainingJobWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false
  sidekiq_options :failures => true

  recurrence { hourly.minute_of_hour(0, 15, 30, 45) }

  def perform()
    now = (DateTime.now.to_i / 15).floor * 15

    submissions = Submission.where(status_code: "PE")

    submissions.each do |submission|
      args = {
        submission_id: submission[:_id].to_s
      }

      enqueue(ProcessSubmission, 'default', 5, args, now)

    end
  end

  def enqueue(worker_klass, worker_queue, frequency, args, now)
    if (now % frequency == 0)
      enqueued = false
      queue = Sidekiq::Queue.new(worker_queue)

      queue.each do |job|
        enqueued = true if job.args[0]['submission_id'] == args[:submission_id]
      end

      worker_klass.perform_async(args) unless enqueued
    end
  end
end
