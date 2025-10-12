class ProcessPostJob
  include Sidekiq::Job

  # Configure job options
  sidekiq_options queue: :default, retry: 3, backtrace: true

  def perform(post_id, action = "process")
    Rails.logger.info "🚀 Processing post #{post_id} with action: #{action}"

    # Find the post
    post = Post.find(post_id)

    case action
    when "process"
      process_post(post)
    when "publish"
      publish_post(post)
    when "archive"
      archive_post(post)
    else
      Rails.logger.error "❌ Unknown action: #{action}"
      raise "Unknown action: #{action}"
    end

    Rails.logger.info "✅ Successfully processed post #{post_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "❌ Post #{post_id} not found: #{e.message}"
    raise
  rescue => e
    Rails.logger.error "❌ Error processing post #{post_id}: #{e.message}"
    raise
  end

  private

  def process_post(post)
    Rails.logger.info "📝 Processing post: #{post.title}"

    # Simulate some processing work
    sleep(2) # Simulate processing time

    # Update post status
    post.update!(status: "processed")

    Rails.logger.info "✅ Post processed successfully: #{post.title}"
  end

  def publish_post(post)
    Rails.logger.info "📢 Publishing post: #{post.title}"

    # Simulate publishing work
    sleep(1)

    # Update post status and published_at
    post.update!(
      status: "published",
      published_at: Time.current
    )

    Rails.logger.info "✅ Post published successfully: #{post.title}"
  end

  def archive_post(post)
    Rails.logger.info "📦 Archiving post: #{post.title}"

    # Simulate archiving work
    sleep(1)

    # Update post status
    post.update!(status: "archived")

    Rails.logger.info "✅ Post archived successfully: #{post.title}"
  end
end

