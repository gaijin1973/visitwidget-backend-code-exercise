class CommentsController < ApplicationController
  http_basic_authenticate_with name: "test", password: "secret", only: :destroy
  protect_from_forgery unless: -> { request.format.json? }

  # GET /comments
  def index
    @comments = Comment.all
    render json: @comments
  end

  # GET /comments/:id
  def show
    @article = Comment.find(params[:id])
    render json: @article
  end

  # POST /comments
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    render :json => @comment.to_json
  end

  private

  def comment_params
    params.require(:comment).permit(:commenter, :body)
  end
end
