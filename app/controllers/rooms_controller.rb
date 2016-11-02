class RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy, :mark_messages_seen]
  before_action :authenticate_user!, :except => [:create_dummy, :show, :accept, :reject]
  before_action :authenticate_freelancer!, only: [:accept, :reject]
  respond_to :html, :json, :js
  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    #debugger
    if user_signed_in?
      @room = current_user.joined_rooms.find params[:id]
      @messages = @room.messages.includes(:user, :attachment, :post).order(:created_at)
    elsif freelancer_signed_in?
      @room = current_freelancer.available_rooms.find params[:id]
      @messages = @room.messages.includes(:user, :attachment, :post).order(:created_at)
      render 'freelancer_show'
    else
      redirect_to root_path
    end
    #@messages = @room.messages.includes(:user, :attachment, :post).order(:created_at).page(params[:page])
  end

  # GET /rooms/new
  def new
    redirect_to root_path unless current_user.client?
    @room = Room.new
    @room.messages.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # GET /rooms/:id/freelancers_list
  def freelancers_list
    @room = current_user.joined_rooms.find params[:id]
    @asigned_freelancer_ids = @room.asigned_freelancers.map(&:id)
    if @asigned_freelancer_ids.any?
      @freelancers = Freelancer.live.where('id not in (?)', @asigned_freelancer_ids)
    else
      @freelancers = Freelancer.live
    end
    @modal_class = 'freelancers-list'
    respond_modal_with @freelancers and return
  end

  # GET /rooms/:id/asign_freelancer
  def asign_freelancer
    if current_user.manager?
      @room = current_user.joined_rooms.find params[:id]
      @freelancer = Freelancer.live.find params[:freelancer_id]
      @success = true
      respond_to do |format|
        format.js do
          begin
            @room.asigned_freelancers << @freelancer
          rescue
            @success = true
            return
          end
        end
        format.html do
          redirect_to root_path
        end
      end
    else
      redirect_to root_path
    end
  end

  def remove_asigned_freelancer
    @room = current_user.joined_rooms.find params[:id]
    @freelancer = Freelancer.live.find params[:freelancer_id]
    @success = true
    respond_to do |format|
      format.js do
        begin
          @room.asigned_freelancers.delete(@freelancer)
        rescue
          @success = false
          return
        end
      end
    end
  end

  # GET /rooms/:id/accept
  def accept
    @room = current_freelancer.asigned_rooms.find params[:id]
    ru = @room.freelancers_rooms.where('freelancer_id = ?', current_freelancer.id)
    if ru.any? && ru[0].status == 'pending'
      ru[0].update_attribute(:status, 'accepted')
        @message = Message.new({body: "Good news, we assigned our expert, #{current_freelancer.first_name} to this task. They should be here shortly. I will let you both take it from here!"})
        @message.room = @room
        @message.user = @room.manager

        @message.save
    end
    redirect_to @room
  end

  # GET /rooms/:id/reject
  def reject
    @room = current_freelancer.asigned_rooms.find params[:id]
    ru = @room.freelancers_rooms.where('freelancer_id = ?', current_freelancer.id)
    if ru.any? && ru[0].status == 'pending'
      ru[0].update_attribute(:status, 'rejected')
    end
    redirect_to root_path
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

        @room.messages.create({:seen => true, :body => 'Please choose one your project timeline', :room => @room, :user => @room.manager})
        @room.messages.create({:seen => true, :body => @room.timeline, :room => @room, :user => @room.user})
        @room.messages.create({:seen => true, :body => 'Please choose the expertise level', :room => @room, :user => @room.manager})
        @room.messages.create({:seen => true, :body => @room.quality, :room => @room, :user => @room.user})
        @room.messages.create({:seen => true, :body => 'What is your budge estimate for this task?', :room => @room, :user => @room.manager})
        @room.messages.create({:seen => true, :body => @room.budget, :room => @room, :user => @room.user})
        @room.messages.create({:seen => true, :body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager})

        if post_body
          message = @room.messages.create(:body => msg_body, :user => @room.user, :seen => true)
          message.post = Post.new(:content => post_body, :title => post_title, :user => @room.user)
          message.post.save!
        end

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

      @room.messages.new({:seen => true, :body => 'Welcome to Kriya. We are pleased to have you here. Please select from the following options', :room => @room, :user => @room.manager})
      @room.messages.new({:seen => true, :body => 'Create Task', :room => @room, :user => @room.user})
      @room.messages.new({:seen => true, :body => 'Hi! I am Kriya, helping startups and businesses to get their work done with the help of top skilled freelancers across the world. Choose one of the fields below:', :room => @room, :user => @room.manager})
      @room.messages.new({:seen => true, :body => @room.category_name, :room => @room, :user => @room.user})
      @room.messages.new({:seen => true, :body => 'Please choose one your project timeline', :room => @room, :user => @room.manager})
      @room.messages.new({:seen => true, :body => @room.timeline, :room => @room, :user => @room.user})
      @room.messages.new({:seen => true, :body => 'Please choose the expertise level', :room => @room, :user => @room.manager})
      @room.messages.new({:seen => true, :body => @room.quality, :room => @room, :user => @room.user})
      @room.messages.new({:seen => true, :body => 'What is your budge estimate for this task?', :room => @room, :user => @room.manager})
      @room.messages.new({:seen => true, :body => @room.budget, :room => @room, :user => @room.user})
      @room.messages.new({:seen => true, :body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager})
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

  def mark_messages_seen
    messages = @room.messages.not_by(current_user).un_seen

    respond_to do |format|
      if messages.update_all(seen: true)
        format.json { render json: '', status: :ok }
      else
        format.json { render json: '', status: :unprocessable_entity }
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
