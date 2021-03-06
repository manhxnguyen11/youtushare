class MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_movie, only: %i[show edit update destroy]

  # GET /movies or /movies.json
  def index
    @movies = Movie.all.includes(:user_actions).order(created_at: :desc)
  end

  # GET /movies/1 or /movies/1.json
  # def show
  # end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  # def edit
  # end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user
    youtube_id = handle_youtube_url(movie_params[:youtube_id])
    if youtube_id.present?
      @movie.youtube_id = youtube_id
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
    respond_to do |format|
      if @movie.save
        format.html { redirect_to movie_url(@movie), notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  # def update
  #   respond_to do |format|
  #     if @movie.update(movie_params)
  #       format.html { redirect_to movie_url(@movie), notice: 'Movie was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @movie }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @movie.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /movies/1 or /movies/1.json
  # def destroy
  #   @movie.destroy

  #   respond_to do |format|
  #     format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  def vote
    return unless params[:movie_id].present? && params[:vote].present?

    movie = Movie.find_by(id: params[:movie_id])
    if movie.present?
      user_action = UserAction.find_or_initialize_by(user_id: current_user.id, movie_id: movie.id)
      user_action.action = params[:vote] == 'vote' ? 'vote' : 'unvote'
      respond_to do |format|
        if user_action.save
          format.html { redirect_to root_path, notice: "#{user_action.action.capitalize} successfully" }
          format.json { render :index, status: :created, location: movie }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: movie.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: movie.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_movie
    @movie = Movie.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def movie_params
    params.require(:movie).permit(:title, :description, :youtube_id)
  end

  def handle_youtube_url(url)
    if url[%r{youtu\.be\/([^\?]*)}]
      youtube_id = Regexp.last_match(1)
    else
      url[%r{^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*}]
      youtube_id = Regexp.last_match(5)
    end
    youtube_id
  end
end
