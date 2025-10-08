class Api::V1::PostsController < ApplicationController
  include Api::V1::ApiResponse
  include Api::V1::CursorPaginator

  def index
    result = paginate_with_cursor(Post.order(:id))

    render_json_with_wrapper(result[:records], pagination: result[:pagination])
  end
end
