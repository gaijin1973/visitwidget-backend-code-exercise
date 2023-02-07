class ArticlesController < ApplicationController
  # Unnecessary if exclusively JSON-based API app (skip forgery protection)
  include ActionController::RequestForgeryProtection
  http_basic_authenticate_with name: "test", password: "secret", except: [:index, :show]
  # Checking CONTENT-TYPE header may be more secure than checking format for CSRF
  protect_from_forgery unless: -> { request.content_type =~ /json/ }
  before_action :retrieve_article, except: [:index, :create, :import]

  # GET /articles
  def index
    # filtering based on search params
    search_terms = []
    search_conditions = {}.to_h
    text_match_attrs = [:title, :body]
    paging_attrs = [:offset, :limit]
    search_params = params.permit(text_match_attrs + [:status] + paging_attrs).to_h

    if Article::VALID_STATUSES.include?(search_params[:status])
      search_conditions[:status] = search_params[:status]
      search_terms << "status = :status"
    end

    search_params.slice(*text_match_attrs).each do |search_term, search_val|
      search_conditions[search_term.to_sym] = "%#{search_val}%"
      search_terms << "#{search_term} LIKE :#{search_term}"
    end

    search_basis = search_conditions.empty? ? Article : Article.where(search_terms.join(" AND "), search_conditions)

    # pagination
    if search_params[:offset].to_i > 0
      search_basis = search_basis.offset(search_params[:offset].to_i)
    end

    max_page_limit = 100
    default_page_limit = 10
    requested_page_limit = search_params[:limit]
    puts requested_page_limit
    if (0...max_page_limit) === requested_page_limit.to_i
      applied_page_limit = requested_page_limit.to_i
    else
      applied_page_limit = default_page_limit
    end
    search_basis = search_basis.limit(applied_page_limit)

    @articles = search_basis.all
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
      render json: rendered_error("create", nil, @article.errors.full_messages),
        status: :bad_request
    end
  end

  # PUT /articles/:id
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: rendered_error("update", params[:id], @article.errors.full_messages),
        status: :bad_request
    end
  end

  # DELETE /articles
  def destroy
    if @article.destroy
      render json: { message: "Article #{params[:id]} successfully destroyed." }
    else
      render json: rendered_error("delete", params[:id], @article.errors.full_messages),
        status: :bad_request
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

  def rendered_error(action, id=nil, msgs=[])
    {
      error: "Unable to #{action} Article#{' ' if id}#{id}. Error#{'s' if msgs.size > 1}: #{msgs.join(', ')}."
    }
  end
end
