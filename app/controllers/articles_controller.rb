class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    # set page views to initial value of zero
    session[:page_views] ||=0
    # for every request, increment the value by 1
    session[:page_views] +=1

    # if user viewed 3 or fewer pages, show article
    # if more than 3 pages, include error message and 401 unauthorized
    if session[:page_views] <= 3
      article = Article.find(params[:id])
      render json: article
    else
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
