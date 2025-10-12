class BulkProcessPostsJob
  include Sidekiq::Job

  # Configure job options
  sidekiq_options queue: :bulk, retry: 2, backtrace: true

  def perform(user_id, action = "process", batch_size = 10)
    Rails.logger.info "🔄 Starting bulk processing for user #{user_id}, action: #{action}, batch_size: #{batch_size}"

    # Get all post IDs for the user
    post_ids = Post.where(author: user_id).pluck(:id)

    Rails.logger.info "📊 Found #{post_ids.count} posts to process"

    # Process posts in batches
    post_ids.each_slice(batch_size) do |batch|
      # Enqueue a batch job for each group
      ProcessPostBatchJob.perform_async(batch, action)
    end

    Rails.logger.info "✅ Enqueued #{post_ids.count / batch_size + 1} batch jobs"
  rescue => e
    Rails.logger.error "❌ Error in bulk processing: #{e.message}"
    raise
  end
end
