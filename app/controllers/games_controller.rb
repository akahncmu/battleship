class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  #now CSRF vulnerable

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  # the board is oriented with 0,0 in top-left
  # on defense 'o' is empty space, '-' is part of a ship that has not been hit, and 'x' is part of a ship that has
  # on offense, 'o' is a space that has not been fired at, '-' is a fired miss, and 'x' is a fired hit
  # TODO: for security, make user object, and place each board under that, 
  def new
    @game = Game.new
    @game.p1d = Array.new(10) { Array.new(10) }
    @game.p1o = Array.new(10) { Array.new(10) }
    @game.p2d = Array.new(10) { Array.new(10) }
    @game.p2o = Array.new(10) { Array.new(10) }
    for i in 0..9
      for j in 0..9
        @game.p1d[i][j]='o'
        @game.p2d[i][j]='o'
        @game.p1o[i][j]='o'
        @game.p2o[i][j]='o'
      end
    end


    @game.p1damage = 0
    @game.p2damage = 0
    if @game.save
      redirect_to @game, notice: 'Game was successfully created.' 
    else
      redirect_to @game, notice: 'Game creation failed.' 
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id]) 
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /games/placeship
  # POST /games/placeship.json
  #TODO: keep track of which ships are already used so players have to place the right quantity of each ship type,
  #      and server will know when setup is complete.  For now, client side would have to track that.
  #TODO: this will partially place the ship, even if it errors later on.  check before placing any part of the ship
  # id is game_id
  # orientation is 'h'orizontal or 'v'ertical
  # player is 1 or 2
  # shipsize is 2, 3, 4, or 5
  # xcoord, ycoord are starting position of the ship.  it will go right or down from there.
  def placeship
    @game = Game.find(params[:id])
    params[:orientation]
    if(params[:player] == '1')
      for i in 0.. params[:shipsize].to_i-1
        if(params[:orientation]=='h')
          if(params[:xcoord].to_i < 0 || params[:ycoord].to_i >= 10 || params[:ycoord].to_i < 0 || params[:xcoord].to_i >= 10 - params[:shipsize].to_i)
            #error handling, ship placed at least partially off the board
            @notice = "iinvalid coordinates, ship placed off the board" 
            @status = 400
          else
            if(@game.p1d[params[:xcoord].to_i][params[:ycoord].to_i+i] == 'o')
              @game.p1d[params[:xcoord].to_i][params[:ycoord].to_i+i] = '-'
              @notice = "ship placed successfully" 
              @status = 200
            elsif(@game.p1d[params[:xcoord].to_i][params[:ycoord].to_i+i] == '-')
              #error-handling: cannot place ship there, it overlaps another ship
              @notice = "invalid ship placement, it overlaps an existing ship" 
              @status = 400
            else
              #error-handling: something went wrong, unexpected character in game board.  Were you trying to place a ship midgame?
              @notice = "unexpected character on the board" 
              @status = 500
            end
          end
        elsif(params[:orientation] == 'v')
          if(params[:xcoord].to_i < 0 || params[:ycoord].to_i >= 10 - params[:shipsize].to_i || params[:ycoord].to_i < 0 || params[:xcoord].to_i >= 10)
            #error handling, ship placed at least partially off the board
            @notice = "invalid coordinates, ship placed off the board"
            @status = 400
          else
            if(@game.p1d[params[:xcoord].to_i+i][params[:ycoord].to_i] == 'o')
              @game.p1d[params[:xcoord].to_i+i][params[:ycoord].to_i] = '-'
              @notice = "ship placed successfully" 
              @status = 200
            elsif(@game.p1d[params[:xcoord].to_i+i][params[:ycoord].to_i] == '-')
              #error-handling: cannot place ship there, it overlaps another ship
              @notice = "invalid ship placement, it overlaps an existing ship" 
              @status = 400
            else
              #error-handling: something went wrong, unexpected character in game board. Were you trying to place a ship midgame?
              @notice = "unexpected character on the board" 
              @status = 500
            end
          end
        else
          #error handling - orientation invalid
          @notice = "invalid orientation" 
          @status = 400
        end
      end
    elsif(params[:player] == '2')
      for i in 0..params[:shipsize].to_i-1
        if(params[:orientation] == 'h')
          if(params[:xcoord].to_i < 0 || params[:ycoord].to_i > 10 || params[:ycoord].to_i < 0 || params[:xcoord].to_i > 10 - params[:shipsize].to_i)
            #error handling, ship placed at least partially off the board
            @notice = "invalid coordinates, ship placed off the board"
            @status = 400
          else
            if(@game.p2d[params[:xcoord].to_i][params[:ycoord].to_i+i] == 'o')
              @game.p2d[params[:xcoord].to_i][params[:ycoord].to_i+i] = '-'
              @notice = "ship placed successfully" 
              @status = 200
            elsif(@game.p2d[params[:xcoord].to_i][params[:ycoord].to_i+i] == '-')
              #error-handling: cannot place ship there, it overlaps another ship
              @notice = "invalid ship placement, it overlaps an existing ship" 
              @status = 400
            else
              #error-handling: something went wrong, unexpected character in game board.  Were you trying to place a ship midgame?
              @notice = "unexpected character on the board" 
              @status = 500
            end
          end
        elsif(params[:orientation] == 'v')
          if(params[:xcoord].to_i < 0 || params[:ycoord].to_i > 10 - params[:shipsize].to_i  || params[:ycoord].to_i < 0 || params[:xcoord].to_i > 10)
            #error handling, ship placed at least partially off the board
            @notice = "invalid coordinates, ship placed off the board" 
            @status = 400
          else
            if(@game.p2d[params[:xcoord].to_i+i][params[:ycoord].to_i] == 'o')
              @game.p2d[params[:xcoord].to_i+i][params[:ycoord].to_i] = '-'
              @notice = "ship placed successfully" 
              @status = 200
            elsif(@game.p2d[params[:xcoord].to_i+i][params[:ycoord].to_i] == '-')
              #error-handling: cannot place ship there, it overlaps another ship
              @notice = "invalid ship placement, it overlaps an existing ship" 
              @status = 400
            else
              #error-handling: something went wrong, unexpected character in game board. Were you trying to place a ship midgame?
              @notice = "unexpected character on the board" 
              @status = 500
            end
          end
        else
          #error handling - orientation invalid
          @notice = "invalid orientation" 
      @status = 400
        end
      end
    else
      #error handlins - playor invalid
      @notice = "invalid player" 
      @status = 400
    end
    if @game.save
      render json: { message: @notice, status: @status } 
    else
      render json: { message:'ship placement failed.', status: 500 }
    end
  end

  # POST /games/fire
  # POST /games/fire
  #TODO: 
  #TODO: for now, it doesn't track when a ship is sunk (I don't remember standard gameplay behavior)
  #       this also means it is up to client to know when damage hits max (2+3+3+4+5 = 17) that the game is over
  # id (ex. 1) is game_id
  # player is 1 or 2
  # xcoord, ycoord are the coordinates being fired at
  def fire
    @game = Game.find(params[:id])
    if(params[:player] == '1')
      if(params[:xcoord].to_i >= 0 && params[:xcoord].to_i < 10 && params[:ycoord].to_i >= 0 && params[:ycoord].to_i < 10)
        if(@game.p2d[params[:xcoord].to_i][params[:ycoord].to_i] == 'o') #miss
          @game.p1o[params[:xcoord].to_i][params[:ycoord].to_i] = '-'
          @notice = "you've missed"
          @status = 200
        elsif(@game.p2d[params[:xcoord].to_i][params[:ycoord].to_i] == 'x') #already fired hit
          #do we allow players to fire on a spot they've already fired? or let them waste a turn?
          @notice = "you've already fired there"
          @status = 200
        elsif(@game.p2d[params[:xcoord].to_i][params[:ycoord].to_i] == '-') #new hit
          @game.p2damage+1
          @game.p2d[params[:xcoord].to_i][params[:ycoord].to_i] = 'x'
          @game.p1o[params[:xcoord].to_i][params[:ycoord].to_i] = 'x'
          @notice = "you've fired a successful hit"
          @status = 200
        else
          #error-handline: unexpected character on the board
          @notice = "unexpected character on the board"
          @status = 500
        end
      else
        #error-handling, fire coordinates out of bounds, or otherwise invalid
        STDERR.puts "!!!!!error coordinates invalid!!!!!"
      end
    elsif(params[:player] =='2')
      if(params[:xcoord].to_i >= 0 && params[:xcoord].to_i < 10 && params[:ycoord].to_i >= 0 && params[:ycoord].to_i < 10)
        if(@game.p1d[params[:xcoord].to_i][params[:ycoord].to_i] == 'o') #miss
          @game.p2o[params[:xcoord].to_i][params[:ycoord].to_i] = '-'
          @notice = "you've missed"
          @status = 200
        elsif(@game.p1d[params[:xcoord].to_i][params[:ycoord].to_i] == 'x') #already fired hit
          #do we allow players to fire on a spot they've already fired? or let them waste a turn?
          @notice = "you've already fired there"
          @status = 200
        elsif(@game.p1d[params[:xcoord].to_i][params[:ycoord].to_i] == '-') #new hit
          @game.p1damage = @game.p1damage+1
          @game.p1d[params[:xcoord].to_i][params[:ycoord].to_i] = 'x'
          @game.p2o[params[:xcoord].to_i][params[:ycoord].to_i] = 'x'
          @notice = "you've fired a successful hit"
          @status = 200
        else
          #error-handline: unexpected character on the board
          @notice = "unexpected character on the board"
          @status = 500
        end
      else
        #error-handling, fire coordinates out of bounds, or otherwise invalid
        @notice = "invalid fire coordinates"
        @status = 400
      end
    else
      #error handling - invalid player
      @notice = "invalid player"
      @status = 400
    end
    if @game.save
      render json: { message: @notice, status: @status } 
    else
      render json: { message:'fire failed.', status: 500 }
    end
  end


  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:p1o, :p1d, :p2o, :p2d, :p1damage, :p2damage)
    end
end
