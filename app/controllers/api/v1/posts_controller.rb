class Api::V1::PostsController < Api::BaseController
  include Api::V1::ApiResponse
  include Api::V1::CursorPaginator

  # Temporary: ensure CSRF protection is disabled
  protect_from_forgery with: :null_session

  def index
    result = paginate_with_cursor(Post.order(:id))

    render_json_with_wrapper(Api::V1::PostSerializer, result[:records], pagination: result[:pagination])
  end

  def show
    @post = Post.find(params[:id])
    render_json_with_wrapper(Api::V1::PostSerializer, @post)
  end

  def create
    result = Api::V1::CreatePostService.call(post_params[:title], post_params[:content], post_params[:author])

    if result[:success]
      render_json_with_wrapper(Api::V1::PostSerializer, result[:post])
    else
      render json: { error: "😵‍💫 #{result[:errors].join(', ')}" }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  private
  def post_params
    Rails.logger.info "🔍 Post Params: #{params.inspect}"
    params.require(:data).permit(:title, :content, :author)
  end
end
