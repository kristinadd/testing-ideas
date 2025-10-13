#!/usr/bin/env ruby

puts "=" * 70
puts "UNDERSTANDING RUBY THREADS"
puts "=" * 70
puts

# =============================================================================
puts "1. What Thread.new creates"
puts "-" * 70

puts "Main thread: Starting at #{Time.now.strftime('%H:%M:%S.%3N')}"

thread = Thread.new do
  puts "  New thread: I exist! #{Time.now.strftime('%H:%M:%S.%3N')}"
  puts "  New thread: My Thread ID is #{Thread.current.object_id}"
  sleep(1)
  puts "  New thread: Done at #{Time.now.strftime('%H:%M:%S.%3N')}"
end

puts "Main thread: I didn't wait! #{Time.now.strftime('%H:%M:%S.%3N')}"
puts "Main thread: My Thread ID is #{Thread.current.object_id}"
puts "Main thread: The new thread's ID is #{thread.object_id}"
puts

thread.join  # Now wait for it
puts

# =============================================================================
puts "2. Threads share memory"
puts "-" * 70

shared_counter = 0  # Shared variable

thread1 = Thread.new do
  5.times do
    shared_counter += 1
    puts "  Thread 1: Counter = #{shared_counter}"
    sleep(0.1)
  end
end

thread2 = Thread.new do
  sleep(0.05)  # Start slightly after thread1
  5.times do
    shared_counter += 1
    puts "  Thread 2: Counter = #{shared_counter}"
    sleep(0.1)
  end
end

thread1.join
thread2.join

puts "Final counter: #{shared_counter} (both threads modified it!)"
puts

# =============================================================================
puts "3. Thread lifecycle"
puts "-" * 70

thread = Thread.new do
  puts "  Thread: Starting..."
  sleep(2)
  puts "  Thread: Finishing..."
end

puts "Thread status: #{thread.status}"    # "run" or "sleep"
puts "Thread alive?: #{thread.alive?}"     # true

sleep(0.5)
puts "After 0.5s - Thread status: #{thread.status}"
puts "After 0.5s - Thread alive?: #{thread.alive?}"

thread.join
puts "After join - Thread status: #{thread.status}"    # false (dead)
puts "After join - Thread alive?: #{thread.alive?}"     # false
puts

# =============================================================================
puts "4. Multiple threads running concurrently"
puts "-" * 70

threads = []

3.times do |i|
  threads << Thread.new do
    thread_name = "Thread #{i + 1}"
    puts "  [#{thread_name}] Started at #{Time.now.strftime('%H:%M:%S.%3N')}"
    sleep(rand(1..3))
    puts "  [#{thread_name}] Finished at #{Time.now.strftime('%H:%M:%S.%3N')}"
  end
end

puts "\nAll 3 threads created and running!"
puts "Main thread waiting for all to finish..."
puts

threads.each(&:join)
puts "All threads finished!"
puts

# =============================================================================
puts "5. Thread local vs shared variables"
puts "-" * 70

shared_var = "SHARED"

thread1 = Thread.new do
  local_var = "LOCAL TO THREAD 1"
  puts "  Thread 1 - Local: #{local_var}"
  puts "  Thread 1 - Shared: #{shared_var}"
  shared_var = "MODIFIED BY THREAD 1"
end

thread2 = Thread.new do
  local_var = "LOCAL TO THREAD 2"
  sleep(0.1)  # Let thread1 modify shared_var first
  puts "  Thread 2 - Local: #{local_var}"
  puts "  Thread 2 - Shared: #{shared_var}"  # Will see thread1's change!
end

thread1.join
thread2.join
puts

# =============================================================================
puts "=" * 70
puts "KEY TAKEAWAYS"
puts "=" * 70
puts
puts "1. Thread.new creates a NEW thread that starts IMMEDIATELY"
puts "2. Main thread continues without waiting (unless you call .join)"
puts "3. Threads run CONCURRENTLY (at the same time)"
puts "4. Threads share the same memory/objects/variables"
puts "5. Each thread has its own local variables and execution pointer"
puts "6. Use .join to wait for a thread to finish"
puts "7. Use .alive? to check if thread is still running"
puts
puts "=" * 70
