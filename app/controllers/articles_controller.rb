class ArticlesController < ApplicationController
  http_basic_authenticate_with name: "test", password: "secret", except: [:index, :show]
  protect_from_forgery unless: -> { request.format.json? }

  # GET /articles
  def index
    # TODO: allow filter and pagination
    @articles = Article.all
    render json: @articles
  end

  # GET /articles/:id
  def show
    @article = Article.find(params[:id])
    render json: @article
  end

  # POST /articles
  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article
    else
      render error: { error: "Unable to create Article." }, status: 400
    end
  end

  # POST /articles/import
  def import
    # TODO: create command that allows for importing articles with comments
  end

  # TODO: add update and delete methods

  private

  def article_params
    params.require(:article).permit(:title, :body, :status)
  end
end
