module Api
  module V1
    class CreatePostService < ApplicationService
      def initialize(title, content, author)
        @title = title
        @content = content
        @author = author
      end

      def call
        post = Post.new
        post.title = @title
        post.content = @content
        post.author = @author
        post.status = "draft"
        post.published_at = nil

        if post.save
          post
        else
          Rails.logger.error "Failed to create post: #{post.errors.full_messages.join(', ')}"
          nil
        end
      rescue => e
        Rails.logger.error "Failed to create post: #{e.message}"
        nil
      end
    end
  end
end
