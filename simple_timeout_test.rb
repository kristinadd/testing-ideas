#!/usr/bin/env ruby
require_relative 'config/environment'

# Get a post to work with
post = Post.first || Post.create!(
  title: "Test Post",
  content: "Testing",
  author: "Tester",
  status: "draft"
)

# =============================================================================
# THREAD 1: Holds lock for 10 seconds
# =============================================================================

thread1 = Thread.new do
  ActiveRecord::Base.connection_pool.with_connection do
    puts "[Thread 1] Starting..."

    ActiveRecord::Base.transaction do
      puts "[Thread 1] Updating post (acquiring lock)..."
      Post.find(post.id).update!(status: "published")
      puts "[Thread 1] ✅ Lock acquired!"
      puts "[Thread 1] Holding lock for 40 seconds..."

      sleep(40)

      puts "[Thread 1] Releasing lock..."
    end

    puts "[Thread 1] ✅ Done!\n"
  end
end

# Wait to ensure Thread 1 gets the lock first
sleep(1)

# =============================================================================
# THREAD 2: Tries to update same post (will timeout!)
# =============================================================================

thread2 = Thread.new do
  ActiveRecord::Base.connection_pool.with_connection do
 30.times do
  puts "I'm a message from thread 2"
 end
  end
end

# Wait for both to complete
thread1.join
thread2.join
