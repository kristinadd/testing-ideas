#!/usr/bin/env ruby

puts "=" * 70
puts "DIFFERENT WAYS TO HANDLE LOCKING IN RUBY"
puts "=" * 70
puts

# =============================================================================
puts "1. MUTEX (Most Common)"
puts "-" * 70

class MutexExample
  def initialize
    @count = 0
    @mutex = Mutex.new
  end

  def increment
    @mutex.synchronize do
      @count += 1
    end
  end

  def count
    @mutex.synchronize { @count }
  end
end

mutex_ex = MutexExample.new
threads = 10.times.map { Thread.new { mutex_ex.increment } }
threads.each(&:join)

puts "Count: #{mutex_ex.count}"
puts "✅ Mutex - Built into Ruby, simple"
puts

# =============================================================================
puts "2. MONITOR (Mutex + Extra Features)"
puts "-" * 70

require 'monitor'

class MonitorExample
  def initialize
    @count = 0
    @lock = Monitor.new  # Like Mutex but reentrant
  end

  def increment
    @lock.synchronize do
      @count += 1
    end
  end

  def increment_twice
    @lock.synchronize do
      increment  # Can call another synchronized method (reentrant!)
      increment
    end
  end

  def count
    @lock.synchronize { @count }
  end
end

monitor_ex = MonitorExample.new
threads = 5.times.map { Thread.new { monitor_ex.increment_twice } }
threads.each(&:join)

puts "Count: #{monitor_ex.count}"
puts "✅ Monitor - Reentrant (can call synchronized methods from synchronized methods)"
puts

# =============================================================================
puts "3. QUEUE (Thread-Safe by Default)"
puts "-" * 70

require 'thread'

queue = Queue.new  # No manual locking needed!

# Producer threads
producers = 3.times.map do |i|
  Thread.new do
    5.times { queue.push("Item from producer #{i + 1}") }
  end
end

# Consumer threads
results = []
results_mutex = Mutex.new

consumers = 3.times.map do |i|
  Thread.new do
    5.times do
      item = queue.pop  # Thread-safe!
      results_mutex.synchronize { results << item }
    end
  end
end

producers.each(&:join)
consumers.each(&:join)

puts "Produced and consumed #{results.size} items"
puts "✅ Queue - Automatically thread-safe, no manual locking!"
puts

# =============================================================================
puts "4. THREAD-SAFE HASH (Alternative to Mutex)"
puts "-" * 70

# Using regular Hash with Mutex
class MutexHash
  def initialize
    @hash = {}
    @mutex = Mutex.new
  end

  def set(key, value)
    @mutex.synchronize { @hash[key] = value }
  end

  def get(key)
    @mutex.synchronize { @hash[key] }
  end

  def size
    @mutex.synchronize { @hash.size }
  end
end

mutex_hash = MutexHash.new
threads = 10.times.map do |i|
  Thread.new { mutex_hash.set("key#{i}", "value#{i}") }
end
threads.each(&:join)

puts "Mutex Hash size: #{mutex_hash.size}"
puts "✅ Manual locking with Mutex"
puts

# Note: Concurrent::Map would be better but requires gem
# We'll show the pattern without requiring the gem

# =============================================================================
puts "5. ATOMIC OPERATIONS (No Lock Needed!)"
puts "-" * 70

class AtomicCounter
  def initialize
    @count = 0
    @mutex = Mutex.new
  end

  # This looks like it needs locking...
  def increment
    @mutex.synchronize { @count += 1 }
  end

  def count
    @mutex.synchronize { @count }
  end
end

# But if we use Thread.current (thread-local storage):
class ThreadLocalCounter
  def increment
    Thread.current[:count] ||= 0
    Thread.current[:count] += 1
  end

  def total
    Thread.list.sum { |t| t[:count] || 0 }
  end
end

tl_counter = ThreadLocalCounter.new
threads = 10.times.map { Thread.new { 10.times { tl_counter.increment } } }
threads.each(&:join)

puts "Thread-local total: #{tl_counter.total}"
puts "✅ Thread-local storage - No lock needed! Each thread has own counter"
puts

# =============================================================================
puts "6. SYNCHRONIZED METHOD (Ruby 3.2+)"
puts "-" * 70

# In Ruby 3.2+, you can use synchronized methods
class SynchronizedExample
  def initialize
    @count = 0
  end

  # Note: This requires Ruby 3.2+ and is experimental
  # For this demo, we'll show the concept with Mutex
  def increment
    # Would be: synchronized def increment
    _synchronized do
      @count += 1
    end
  end

  def count
    _synchronized { @count }
  end

  private

  def _synchronized(&block)
    @_mutex ||= Mutex.new
    @_mutex.synchronize(&block)
  end
end

sync_ex = SynchronizedExample.new
threads = 10.times.map { Thread.new { sync_ex.increment } }
threads.each(&:join)

puts "Count: #{sync_ex.count}"
puts "✅ Pattern: Synchronized methods (Mutex wrapper)"
puts

# =============================================================================
puts "=" * 70
puts "SUMMARY: WHEN TO USE EACH"
puts "=" * 70
puts
puts "1. Mutex:"
puts "   - Basic thread safety"
puts "   - Single process"
puts "   - Most common choice"
puts
puts "2. Monitor:"
puts "   - Need reentrant locks"
puts "   - Complex synchronization"
puts "   - Condition variables"
puts
puts "3. Queue:"
puts "   - Producer-consumer pattern"
puts "   - Automatically thread-safe"
puts "   - No manual locking needed"
puts
puts "4. Thread-Local Storage:"
puts "   - Each thread needs own data"
puts "   - No sharing needed"
puts "   - No locks needed!"
puts
puts "5. Database Locks (Rails):"
puts "   - Multi-process coordination"
puts "   - Persistent state"
puts "   - Best for Rails apps"
puts
puts "6. Redis Locks:"
puts "   - Distributed systems"
puts "   - Multiple servers"
puts "   - Microservices"
puts
puts "For most Ruby apps: Mutex is enough!"
puts "For Rails/Sidekiq: Usually just use local variables!"
puts
puts "=" * 70
