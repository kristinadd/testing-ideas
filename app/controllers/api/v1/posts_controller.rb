class Api::V1::PostsController < ApplicationController
  include Api::V1::ApiResponse

  def index
    @posts = Post.all
    render_json_with_wrapper(@posts)
  end

  def show
    @post = Post.find(params[:id])
    render_json_with_wrapper(@post)
  end
end
