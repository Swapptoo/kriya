class FreelancersRoomsController < ApplicationController
  before_action :authenticate_user!

  # GET /freelancers_rooms
  # GET /freelancers_rooms.json
  def index
  end

  # GET /freelancers_rooms/1
  # GET /freelancers_rooms/1.json
  def show
  end

  # GET /freelancers_rooms/1/edit
  def edit
  end

  # POST /freelancers_rooms
  # POST /freelancers_rooms.json
  def create
  end

  # PUT /freelancers_rooms/1
  # PUT /freelancers_rooms/1.json
  def update
    @freelancers_room = FreelancersRooms.find(params[:id])
    respond_to do |format|
      if @freelancers_room.update(freelancers_room_params)
        if @freelancers_room.status == 'completed'
          message = Message.new({:body => 'The task is complete and the freelancer will be disconnected', :room => @freelancers_room.room, :user => @freelancers_room.room.manager, :msg_type => 'bot-task-finished'})
        elsif @freelancers_room.status == 'more_work'
          message = Message.new({:body => 'Client has more work for you, details will be given shortly', :room => @freelancers_room.room, :user => @freelancers_room.room.manager, :msg_type => 'bot-continue-work'})  
        elsif @freelancers_room.status == 'not_finished'
          message = Message.new({:body => 'The work is not finished.', :room => @freelancers_room.room, :user => @freelancers_room.room.manager, :msg_type => 'bot-task-not-finished'})
        end
        message.save
        message.process_command
        format.html { redirect_to root_path, notice: 'FreelancerRoom was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @freelancers_room.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def freelancers_room_params
      params.require(:freelancers_room).permit(:freelancer_id, :room_id, :status)
    end
end
