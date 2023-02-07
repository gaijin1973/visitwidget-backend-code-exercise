# https://guides.rubyonrails.org/testing.html#functional-tests-for-your-controllers
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest

  fixtures :articles

  AUTH_HEADER = { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("test", "secret") }
  HTML_CONTENT_TYPE = "text/html; charset=utf-8"
  JSON_CONTENT_TYPE = "application/json; charset=utf-8"
  TEXT_CONTENT_TYPE = "text/plain; charset=utf-8"

# GET /articles/

  test "should get index" do
    get articles_url, as: :json
    assert_response :success
    assert_equal JSON_CONTENT_TYPE, @response.content_type
    articles = JSON.parse(@response.body)
    assert_equal 2, articles.size
  end

# GET /articles/:id

  test "should show existing article" do
    first_article = articles(:one)
    get article_url(first_article), as: :json
    assert_response :success
    assert_equal JSON_CONTENT_TYPE, @response.content_type
    article_details = JSON.parse(@response.body)
    assert_equal 2, articles.size
  end

  test "should get 404 for invalid article path" do
    first_article = articles(:one)
    get article_url(first_article.id-1000), as: :json
    assert_response :not_found
    assert_equal TEXT_CONTENT_TYPE, @response.content_type
    assert_match "404 Not Found", @response.body
  end

# POST /articles/

  test "should create article" do
    test_body = "Body of article #{Time.current}"
    assert_difference("Article.count") do
      post articles_url,
        params: {
          article: {
            body: test_body,
            title: "Testing article creation",
            status: "public"
          }
        },
        headers: AUTH_HEADER,
        as: :json
    end
    last_article = Article.last
    assert_equal test_body, last_article.body
  end

  test "should prevent article creation without title" do
    test_body = "Body of article #{Time.current}"
    assert_no_difference("Article.count") do
      post articles_url,
        params: {
          article: {
            body: test_body,
            status: "public"
          }
        },
        headers: AUTH_HEADER,
        as: :json
    end
    assert_response :bad_request
    assert_equal JSON_CONTENT_TYPE, @response.content_type
    error_details = json_to_hwia(@response.body)
    assert_match "Unable to create Article.", error_details[:error]
    assert_match "Title can't be blank", error_details[:error]
  end

  ["too_short", nil].each do |bad_body_value|
    test "should prevent article creation with invalid body #{bad_body_value || 'nil'}" do
      assert_no_difference("Article.count") do
        post articles_url,
          params: {
            article: {
              body: bad_body_value,
              title: "Testing article creation with invalid body",
              status: "public"
            }
          },
          headers: AUTH_HEADER,
          as: :json
      end
      assert_response :bad_request
      assert_equal JSON_CONTENT_TYPE, @response.content_type
      error_details = json_to_hwia(@response.body)
      assert_match "Unable to create Article.", error_details[:error]
      if bad_body_value
        assert_match "Body is too short (minimum is 10 characters)", error_details[:error]
      else
        assert_match "Body can't be blank", error_details[:error]
      end
    end
  end

  ["invalid", nil].each do |bad_status_value|
    test "should prevent article creation with invalid status #{bad_status_value || 'nil'}" do
      assert_no_difference("Article.count") do
        post articles_url,
          params: {
            article: {
              body: "Body of article #{Time.current}",
              title: "Testing article creation with invalid body",
              status: bad_status_value
            }
          },
          headers: AUTH_HEADER,
          as: :json
      end
      assert_response :bad_request
      assert_equal JSON_CONTENT_TYPE, @response.content_type
      error_details = json_to_hwia(@response.body)
      assert_match "Unable to create Article.", error_details[:error]
      assert_match "Status is not included in the list", error_details[:error]
    end
  end

  test "should prevent unauthenticated article creation" do
    test_body = "Body of article #{Time.current}"
    assert_no_difference("Article.count") do
      post articles_url,
        params: {
          article: {
            body: test_body,
            title: "Testing article creation",
            status: "public"
          }
        },
        as: :json
    end
    assert_response :unauthorized
    assert_equal HTML_CONTENT_TYPE, @response.content_type
    assert_match "HTTP Basic: Access denied.", @response.body
  end

# PUT /articles/

  test "should update article" do
    first_article = Article.first
    original_body = first_article.body
    test_body = "Body of article #{Time.current}"
    assert_not_equal test_body, original_body
    assert_no_difference("Article.count") do
      put article_url(first_article),
        params: {
          article: {
            body: test_body,
            title: first_article.title,
            status: first_article.status
          }
        },
        headers: AUTH_HEADER,
        as: :json
    end
    assert_response :success
    assert_equal JSON_CONTENT_TYPE, @response.content_type
    article_details = json_to_hwia(@response.body)
    assert_equal 2, articles.size
    assert_equal test_body, article_details[:body]
    assert_equal test_body, Article.first.body
  end

  test "should fail update for an invalid article ID" do
    first_article = Article.first
    test_body = "Body of article #{Time.current}"
    put article_url(first_article.id-1000),
      params: {
        article: {
          body: test_body,
          title: first_article.title,
          status: first_article.status
        }
      },
      headers: AUTH_HEADER,
      as: :json
    assert_response :not_found
    assert_equal TEXT_CONTENT_TYPE, @response.content_type
    assert_match "404 Not Found", @response.body
  end

  test "should prevent unauthenticated article updates" do
    first_article = Article.first
    test_body = "Body of article #{Time.current}"
    assert_no_difference("Article.count") do
      put article_url(first_article),
        params: {
          article: {
            body: test_body,
            title: first_article.title,
            status: first_article.status
          }
        },
        as: :json
    end
    assert_response :unauthorized
    assert_equal HTML_CONTENT_TYPE, @response.content_type
    assert_match "HTTP Basic: Access denied.", @response.body
  end

# DELETE /articles/

  test "should delete article" do
    assert_equal 2, Article.count
    assert_equal 2, Comment.count
    first_article = Article.first
    assert_difference("Article.count", -1) do
      delete article_url(first_article),
        headers: AUTH_HEADER,
        as: :json
    end
    assert_response :success
    assert_equal 1, Article.count
    assert_equal 1, Comment.count
  end

  test "should show error for deleting invalid article path" do
    assert_no_difference("Article.count") do
      delete article_url(Article.first.id-1000),
        headers: AUTH_HEADER,
        as: :json
    end
    assert_response :not_found
    assert_equal TEXT_CONTENT_TYPE, @response.content_type
    assert_match "404 Not Found", @response.body
  end

  test "should prevent unauthenticated article deletion" do
    assert_no_difference("Article.count") do
      delete article_url(Article.first),
        as: :json
    end
    assert_response :unauthorized
    assert_equal HTML_CONTENT_TYPE, @response.content_type
    assert_match "HTTP Basic: Access denied.", @response.body
  end

end
