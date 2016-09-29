class RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, :except => :create_dummy

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    #debugger
    @room = current_user.joined_rooms.find params[:id]
    #@messages = @room.messages.includes(:user, :attachment, :post).order(:created_at).page(params[:page])
    @messages = @room.messages.includes(:user, :attachment, :post).order(:created_at)
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
    #debugger
    @room = Room.new(room_params)
    @room.user = current_user
    @room.manager = User.where(:email => 'manager@goomp.co').first || User.where.not(id: current_user.id).all.sample

    respond_to do |format|
      if @room.save
        msg_body = params.dig(:room, :messages, :body)
        post_body = params.dig(:room, :messages, :post, :content)
        post_title = params.dig(:room, :messages, :post, :title)

        @room.messages.create({:body => 'Please choose one your project timeline', :room => @room, :user => @room.manager})
        @room.messages.create({:body => @room.timeline, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'Please choose the expertise level', :room => @room, :user => @room.manager})
        @room.messages.create({:body => @room.quality, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'What is your budge estimate for this task?', :room => @room, :user => @room.manager})
        @room.messages.create({:body => @room.budget, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager})

        if post_body
          message = @room.messages.create :body => msg_body, :user => @room.user
          message.post = Post.new(:content => post_body, :title => post_title, :user => @room.user)
          message.post.save!
        end

        UserNotifierMailer.notify_room_user(@room).deliver
        UserNotifierMailer.notify_room_manager(@room).deliver

        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /tasks/dummy
  def create_dummy
    session[:sign_up_dummy_room] = Room.new(room_params)

    respond_to do |format|
      format.json { head :no_content}
    end
  end

  #GET /tasks/from_sign_up
  def create_room_from_sign_up
    session_dummy = session.delete(:sign_up_dummy_room)
    if session_dummy
      @room = Room.new(session_dummy)
      @room.user = current_user
      @room.manager = User.where(:email => 'manager@goomp.co').first || User.where.not(id: current_user.id).all.sample

      @room.messages.new({:body => 'Welcome to Kriya. We are pleased to have you here. Please select from the following options', :room => @room, :user => @room.manager})
      @room.messages.new({:body => 'Create Task', :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Hi! I am Kriya, helping startups and businesses to get their work done with the help of top skilled freelancers across the world. Choose one of the fields below:', :room => @room, :user => @room.manager})
      @room.messages.new({:body => @room.category_name, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please choose one your project timeline', :room => @room, :user => @room.manager})
      @room.messages.new({:body => @room.timeline, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please choose the expertise level', :room => @room, :user => @room.manager})
      @room.messages.new({:body => @room.quality, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'What is your budge estimate for this task?', :room => @room, :user => @room.manager})
      @room.messages.new({:body => @room.budget, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager})
      @room.messages.last.create_attachment(:message => @room.messages.last, :html => "<br/>#{view_context.link_to 'Add Description', new_post_path, :data => {:modal => true}, :class => 'mini ui green button custom-padding'}")

      if @room.save!
        redirect_to @room and return
      end
    end
    redirect_to root_path
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
        :messages_attributes => [:id, :body,
                              :post_attributes => [:id, :content, :title]]
      )
    end
end
