class Api::V1::PostsController < ApplicationController
  include Api::V1::ApiResponse

  def index
    @posts = Post.all
    render_json_with_wrapper(@posts,
      meta: {
        total: @posts.count,
        page: 1,
        per_page: @posts.count
      },
      links: {
        self: api_v1_posts_url,
        first: api_v1_posts_url,
        last: api_v1_posts_url
      }
    )
  end

  def show
    @post = Post.find(params[:id])
    render_json_with_wrapper(@post)
  end
end
