#!/usr/bin/env ruby
# Load the Rails environment so we have access to models
require_relative 'config/environment'

puts "=" * 80
puts "DATABASE LOCK TIMEOUT TEST"
puts "=" * 80
puts

# Find or create a test post
post = Post.first || Post.create!(
  title: "Test Post for Locking",
  content: "Testing concurrent updates",
  author: "Test User",
  status: "draft"
)

puts "Using Post ##{post.id}: #{post.title}"
puts "Initial status: #{post.status}"
puts
puts "Configuration:"
puts "  - Thread 1 will hold lock for: 10 seconds"
puts "  - Database timeout (database.yml): 5 seconds"
puts "  - Expected: Thread 2 should TIMEOUT after 5 seconds"
puts
puts "=" * 80
puts

def log(thread_name, message)
  timestamp = Time.now.strftime("%H:%M:%S.%3N")
  puts "[#{timestamp}] [#{thread_name}] #{message}"
end

# =============================================================================
# THREAD 1: Holds the lock for 10 seconds (longer than timeout!)
# =============================================================================

thread1 = Thread.new do
  ActiveRecord::Base.connection_pool.with_connection do
    log("THREAD 1", "🚀 Starting...")

    ActiveRecord::Base.transaction do
      log("THREAD 1", "✅ Transaction opened (BEGIN)")

      sleep(0.5)

      log("THREAD 1", "About to UPDATE - this will acquire the lock...")
      Post.find(post.id).update!(status: "processing")
      log("THREAD 1", "🔒 LOCK ACQUIRED!")

      log("THREAD 1", "Holding lock for 10 seconds (longer than 5 sec timeout)...")
      log("THREAD 1", "Thread 2 should timeout before I finish!")

      sleep(10)

      log("THREAD 1", "10 seconds passed. About to COMMIT...")
    end

    log("THREAD 1", "✅ COMMIT executed")
    log("THREAD 1", "🔓 LOCK RELEASED!")
    log("THREAD 1", "✨ Finished!")
  end
rescue => e
  log("THREAD 1", "❌ ERROR: #{e.class} - #{e.message}")
end

# Give thread 1 time to acquire the lock
sleep(1)

# =============================================================================
# THREAD 2: Tries to update SAME post - should timeout!
# =============================================================================

thread2 = Thread.new do
  ActiveRecord::Base.connection_pool.with_connection do
    log("THREAD 2", "🚀 Starting...")

    ActiveRecord::Base.transaction do
      log("THREAD 2", "✅ Transaction opened (BEGIN)")

      log("THREAD 2", "About to UPDATE the SAME post...")
      log("THREAD 2", "⏸️  Trying to acquire lock (will wait up to 5 seconds)...")

      start_time = Time.now

      # This will BLOCK and should TIMEOUT after 5 seconds!
      Post.find(post.id).update!(status: "published")

      wait_time = Time.now - start_time
      log("THREAD 2", "🎉 UPDATE succeeded after #{wait_time.round(2)} seconds!")
    end

    log("THREAD 2", "✅ COMMIT executed")
    log("THREAD 2", "✨ Finished!")
  end
rescue ActiveRecord::StatementInvalid => e
  wait_time = Time.now - start_time rescue 0
  if e.message.include?("database is locked") || e.message.include?("busy")
    log("THREAD 2", "❌ TIMEOUT after #{wait_time.round(2)} seconds!")
    log("THREAD 2", "   Database was locked by Thread 1")
    log("THREAD 2", "   Exceeded timeout of 5 seconds (database.yml)")
    log("THREAD 2", "   Error: #{e.class}")
  else
    log("THREAD 2", "❌ ERROR: #{e.class} - #{e.message}")
  end
rescue => e
  log("THREAD 2", "❌ ERROR: #{e.class} - #{e.message}")
end

# Wait for both threads to complete
thread1.join
thread2.join

puts
puts "=" * 80
puts "SUMMARY"
puts "=" * 80
puts
puts "What should happen:"
puts "  1. Thread 1 acquires lock and holds it for 10 seconds"
puts "  2. Thread 2 tries to acquire same lock after 1 second"
puts "  3. Thread 2 waits at the database level"
puts "  4. After 5 seconds, Thread 2's wait exceeds timeout"
puts "  5. Database raises SQLite3::BusyException"
puts "  6. Thread 2 catches the error and exits"
puts "  7. Thread 1 continues and finishes after 10 seconds"
puts
puts "Key: Thread 1 doesn't timeout - it HOLDS the lock"
puts "     Thread 2 timeouts - it's WAITING for the lock"
puts "=" * 80
