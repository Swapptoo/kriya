class RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :collect_rooms, only: %w(index show new)
  after_action :verify_policy_scoped, only: :index

  # GET /rooms
  # GET /rooms.json
  def index
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @room = @rooms.find params[:id]
    @messages = @room.messages.includes(:user, :attachment).order(:created_at).page(params[:page])
  end

  # GET /rooms/new
  def new
    @room = Room.new
    @room.messages.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)
    @room.user = current_user
    @room.manager = User.where.not(id: current_user.id).all.sample

    respond_to do |format|
      if @room.save
        msg_body = params.dig(:room, :messages, :body)
        @room.messages.create body: msg_body, user: current_user if msg_body
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(
        :category_name,
        :budget,
        :timeline,
        :quality,
        :description,
        messages_attributes: [:id, :body]
      )
    end

  def collect_rooms
    @rooms = policy_scope(Room).includes(:user)
  end
end
