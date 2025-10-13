#!/usr/bin/env ruby
require_relative 'config/environment'

puts "=" * 70
puts "HOW SIDEKIQ USES THREADS"
puts "=" * 70
puts

# =============================================================================
# Simulate Sidekiq's Thread Pool
# =============================================================================

class SimplifiedSidekiq
  def initialize(concurrency:)
    @concurrency = concurrency
    @job_queue = []
    @mutex = Mutex.new
  end

  # Add jobs to the queue (like Redis)
  def enqueue(job_class, *args)
    @mutex.synchronize do
      @job_queue << { class: job_class, args: args }
    end
  end

  # Start worker threads (like Sidekiq does)
  def start
    puts "Starting #{@concurrency} worker threads..."
    puts "(Just like Sidekiq does with Thread.new!)"
    puts

    # Create worker threads (this is what Sidekiq does!)
    @threads = @concurrency.times.map do |i|
      Thread.new do
        worker_loop(i + 1)
      end
    end

    # Wait for all jobs to complete
    sleep(1) while !@job_queue.empty?

    puts "\nAll jobs complete. Stopping workers..."
    @threads.each(&:kill)
  end

  private

  def worker_loop(worker_id)
    loop do
      job = nil

      # Get next job from queue
      @mutex.synchronize do
        job = @job_queue.shift
      end

      if job
        puts "[Worker #{worker_id}] Processing #{job[:class].name} with args: #{job[:args]}"

        # Execute the job (this is your job code!)
        job[:class].new.perform(*job[:args])

        puts "[Worker #{worker_id}] ✅ Completed #{job[:class].name}"
      else
        sleep(0.1)  # Wait for more jobs
      end
    end
  end
end

# =============================================================================
# Fake Jobs (like your Sidekiq jobs)
# =============================================================================

class FakeJob
  def perform(job_id)
    puts "  [#{self.class.name}] Running job #{job_id} on thread #{Thread.current.object_id}"
    sleep(0.5)  # Simulate work
  end
end

class ProcessPostJob < FakeJob
end

class BulkProcessPostsJob < FakeJob
end

# =============================================================================
# Run the simulation
# =============================================================================

puts "Creating Sidekiq-like worker pool with 5 threads..."
sidekiq = SimplifiedSidekiq.new(concurrency: 5)

puts "\nEnqueuing 10 jobs..."
10.times do |i|
  job_class = i.even? ? ProcessPostJob : BulkProcessPostsJob
  sidekiq.enqueue(job_class, i + 1)
end

puts "\nJob queue ready. Starting workers..."
puts "(Each worker is a Ruby Thread created with Thread.new)"
puts
puts "-" * 70
puts

sidekiq.start

puts
puts "=" * 70
puts "SUMMARY"
puts "=" * 70
puts
puts "What we just did:"
puts "  1. Created 5 worker threads with Thread.new (like Sidekiq)"
puts "  2. Each thread ran a loop waiting for jobs"
puts "  3. When jobs arrived, threads picked them up and ran them"
puts "  4. Multiple jobs ran CONCURRENTLY on different threads"
puts
puts "This is EXACTLY how Sidekiq works:"
puts "  - Sidekiq creates threads with Thread.new"
puts "  - Each thread is a Ruby thread (same as Thread.new)"
puts "  - Your job code runs inside those threads"
puts "  - Multiple jobs can run at the same time"
puts
puts "This is why thread safety matters in Sidekiq jobs!"
puts "=" * 70
