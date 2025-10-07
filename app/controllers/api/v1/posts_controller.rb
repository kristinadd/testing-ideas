class Api::V1::PostsController < ApplicationController
  def index
    @posts = Post.all
    render json: @posts, each_serializer: PostSerializer
  end

  def show
    @post = Post.find(params[:id])
    render json: @post, serializer: PostSerializer
  end
end
