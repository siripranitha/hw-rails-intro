class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @movies = Movie.all
      @all_ratings = Movie.get_ratings
      @sorting = params[:sorting]
      
      if params[:ratings]
        @chosen_ratings = params[:ratings].keys
      else
        @chosen_ratings = @all_ratings
      end
      
      session[:sorting] = params[:sorting] if @sorting
      
      
      if params[:ratings] || params[:commit] == 'Refresh'
        session[:ratings] = params[:ratings]
      end
      
      if !params[:sorting] && session[:sorting] && params[:ratings]
       flash.keep
       return redirect_to movies_path(:sorting => session[:sorting], :ratings=> params[:ratings])
      elsif !params[:sorting] && session[:sorting] && !params[:ratings]
        flash.keep
        return redirect_to movies_path(:sorting=> session[:sorting], :ratings=> session[:ratings])
      elsif params[:sorting] && !params[:ratings]
        flash.keep
        return redirect_to movies_path(:sorting=> params[:sorting], :ratings=> session[:ratings])
      end
      
      if @sorting
        return @movies = @movies.where(rating: @chosen_ratings).order(@sorting)
        
      else
        return @movies = @movies.where(rating: @chosen_ratings)
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
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end