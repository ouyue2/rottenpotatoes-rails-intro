class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.uniq.order(:rating).pluck(:rating)
    @selected_sort=''
    @selected_ratings= []
    isredirect=false

    if params[:sort]
      @selected_sort = params[:sort]
      session[:sort] = @selected_sort
    elsif session[:sort]
      @selected_sort = session[:sort]
      isredirect = true
    else
      @selected_sort = nil
    end
    
    if(params[:ratings])
      params[:ratings].each {|key, value| @selected_ratings << key}
      session[:ratings] = @selected_ratings
    elsif session[:ratings]
      @selected_ratings = session[:ratings]
      isredirect = true
    else
      @selected_ratings = nil
    end
    @selected_ratings.each { |rating|  params[rating] = 1 }  if @selected_ratings
    
    if isredirect
      redirect_to movies_path :ratings=>@selected_ratings, :sort=>@selected_sort
    else
      if @selected_ratings&&@selected_sort
        @movies = Movie.where(:rating => @selected_ratings).order(@selected_sort)
      elsif @selected_ratings
        @movies = Movie.where(:rating => @selected_ratings)
      elsif @selected_sort
        @movies = Movie.order(@selected_sort)
      else
        @movies = Movie.all
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
