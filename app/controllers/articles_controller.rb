class ArticlesController < ApplicationController
  http_basic_authenticate_with name: "test", password: "secret", except: [:index, :show]
  protect_from_forgery unless: -> { request.format.json? }
  before_action :retrieve_article, except: [:index, :create, :import]

  # GET /articles
  def index
    # TODO: allow filter and pagination
    @articles = Article.all
    render json: @articles
  end

  # GET /articles/:id
  def show
    render json: @article
  end

  # POST /articles
  def create
    @article = Article.new(article_params)
    if @article.save
      render json: @article
    else
      render rendered_error("create", nil, @article.errors.full_messages)
    end
  end

  # PUT /articles/:id
  def update
    if @article.update_attributes(article_params)
      render json: @article
    else
      render rendered_error("update", params[:id], @article.errors.full_messages)
    end
  end

  # DELETE /articles
  def delete
    if @article.destroy
      render message: { error: "Article #{params[:id]} successfully deleted." }
    else
      render rendered_error("delete", params[:id], @article.errors.full_messages)
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

  def retrieve_article
    @article = Article.find(params[:id])
  end

  def rendered_error(action, id=nil, msgs=[], status=400)
    {error: { error: "Unable to #{action} Article#{' ' if id}#{id}. Error#{'s' if msgs.size > 1}: #{msgs.join(', ')}" }, status: status}
  end
end
