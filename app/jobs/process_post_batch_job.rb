class ProcessPostBatchJob
  include Sidekiq::Job

  # Configure job options
  sidekiq_options queue: :default, retry: 3, backtrace: true

  def perform(post_ids, action = "process")
    Rails.logger.info "📦 Processing batch of #{post_ids.count} posts, action: #{action}"

    # Process each post in the batch
    post_ids.each do |post_id|
      ProcessPostJob.perform_async(post_id, action)
    end

    Rails.logger.info "✅ Enqueued #{post_ids.count} individual jobs"
  rescue => e
    Rails.logger.error "❌ Error processing batch: #{e.message}"
    raise
  end
end

