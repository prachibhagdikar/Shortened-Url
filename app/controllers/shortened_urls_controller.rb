class ShortenedUrlsController < ApplicationController
  before_action :find_url, :only => [:show, :shortened]
  skip_before_filter :verify_authenticity_token

  def index
    @url = ShortenedUrl.new
    if params[:short_url].present?
      @shortened_url = ShortenedUrl.find_by_short_url(params[:short_url])
      host = request.host_with_port
      @original_url = @shortened_url.sanitize_url
      @short_url = host + '/' + @shortened_url.short_url
    end
    if params[:existing_url].present?
      @shortened_url = ShortenedUrl.find_by_short_url(params[:existing_url])
      host = request.host_with_port
      @original_url = @shortened_url.sanitize_url
      @short_url = host + '/' + @shortened_url.short_url
    end
  end

  def show
    redirect_to @url.sanitize_url  
  end

  def create
    @url = ShortenedUrl.new
    @url.original_url = params[:original_url]
    @url.sanitize
    if @url.new_url?
      if @url.save
        redirect_to root_url(:short_url => @url.short_url)
      else
        flash[:error] = "Check the error below:"
        render :index
      end
    else
      @already_present_url = @url.find_duplicate
      @already_present_url.update(:visited => @already_present_url.visited + 1)
      flash[:notice] = "A short link for this URL is already in our database."
      redirect_to root_url(:existing_url => @already_present_url.short_url)
    end
  end

  def shortened
    @url = ShortenedUrl.find_by_short_url(params[:short_url])
    host = request.host_with_port
    @original_url = @url.sanitize_url
    @short_url = host + '/' + @url.short_url
  end

  def fetch_original_url
    fetch_url = ShortenedUrl.find_by_short_url(params[:short_url])
    redirect_to fetch_url.sanitize_url
  end

  private

  def find_url
    @url = ShortenedUrl.find_by_short_url(params[:short_url])
  end

  def url_params
    params.require(:url).permit(:original_url)
  end
end
  