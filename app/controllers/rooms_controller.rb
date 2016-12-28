class RoomsController < ApplicationController
  before_action :set_room, only: [:edit, :update, :destroy, :mark_messages_seen, :deny_slack]
  before_action :authenticate_user!, :except => [:create_dummy, :show, :accept, :reject, :mark_messages_seen, :deny_slack]
  before_action :authenticate_freelancer!, only: [:accept, :reject]
  before_action :authenticate!, only: [:mark_messages_seen, :deny_slack]
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
      begin
        @room = current_freelancer.available_rooms.find params[:id]
        @messages = @room.messages.for_freelancer.includes(:user, :attachment, :post).order(:created_at)
        render 'freelancer_show'
      rescue
        redirect_to @room.posts.first.public_url and return if @room.posts.first.present?
        redirect_to root_path and return
      end
    else
      room = Room.find(params[:id])
      redirect_to room.posts.first.public_url and return if room.posts.first.present?
      redirect_to root_path and return
    end

    session[:room_id] = @room.id if @room.present?
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

  def deny_slack
    user = current_user.presence || current_freelancer
    channel = user.slack_channels.find_or_create_by(room: @room)
    message = @room.messages.find_or_create_by(msg_type: "slack-#{user.type}", user: @room.manager, body: 'Thanks for that. One last question. Do you use Slack? Please click yes if you do as we deeply integrate with Slack to increase your productivity and communicate easily with the Kriya workforce.')
    message.attachment.try(:destroy)
    message.create_attachment(:message => @room.messages.last, :html => "<br/>#{view_context.link_to 'Pass', '#', :class => 'mini ui green button custom-padding slack'}")

    @room.messages.find_or_create_by(user: @room.manager, body: 'Alright, no problem', msg_type: 'bot-reject-slack')
    @room.messages.find_or_create_by(user: @room.manager, body: 'And thanks for answering all my questions. I sent out requests to around 10 matching workforce, one of them will be joining us here shortly!', msg_type: 'bot-thanks-client')
    @room.messages.find_or_create_by(user: @room.manager, body: 'Please note, there\'s a 6-12 hrs as you created this after 10am PST, since our workforce is distributed and majority are international. ', msg_type: 'bot-remark-time-diff') if @room.created_at.in_time_zone("Pacific Time (US & Canada)").hour >= 10

    channel.inactive!

    redirect_to room_path(@room)
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
            @room.notify_new_gig(@freelancer)
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
          @room.reset
          render inline: 'location.reload();'
        rescue
          @success = false
          return
        end
      end
    end
  end

  # GET /rooms/:id/accept
  def accept
    @room = current_freelancer.asigned_rooms.find(params[:id])
    freelancer_room = @room.freelancers_rooms.find_by(freelancer_id: current_freelancer.id)

    if @room.in_progress_freelancers.blank? && freelancer_room.present? && freelancer_room.status == 'pending'
      freelancer_room.update_attribute(:status, 'accepted')
      @message = Message.new({ body: "Good news, we assigned our expert, #{current_freelancer.first_name} to this task. They should be here shortly. I will let you both take it from here!" })
      @message.room = @room
      @message.user = @room.manager
      @message.msg_type = 'bot-task-accepted'
      @message.save
      @message.process_command

      @room.create_escrow_payment_message unless @room.first_paid_amount_cents?
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
    @room.manager = User.where(:email => 'manager@kriya.ai').first || User.where.not(id: current_user.id).all.sample

    respond_to do |format|
      if @room.save
        msg_body = params.dig(:room, :messages, :body)
        post_body = params.dig(:room, :messages, :post, :content)
        post_title = params.dig(:room, :messages, :post, :title)

        @room.messages.create({:body => 'Please choose your project timeline', :room => @room, :user => @room.manager, :msg_type => 'bot-timeline'})
        @room.messages.create({:body => @room.timeline, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'Please choose the expertise level', :room => @room, :user => @room.manager, :msg_type => 'bot-expertise-level'})
        @room.messages.create({:body => @room.quality, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'What is your budget estimate for this task in USD? (Kriya fees will apply - 5% for budget > $500, 10% otherwise)', :room => @room, :user => @room.manager, :msg_type => 'bot-budget-estimate'})
        @room.messages.create({:body => @room.budget, :room => @room, :user => @room.user})
        @room.messages.create({:body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager, :msg_type => 'bot-description'})

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
    @room = session.delete(:sign_up_dummy_room)
    if @room
      @room.user = current_user
      @room.manager = manager

      @room.messages.new({:body => 'Welcome to Kriya. Thank you for choosing us. Please select from the following options', :room => @room, :user => @room.manager, :msg_type => 'bot-welcome'})
      @room.messages.new({:body => 'Create Task', :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Hi! I am Kriya, helping startups and businesses complete tasks with the help of skilled global freelancers. Choose one of the fields below:', :room => @room, :user => @room.manager, :msg_type => 'bot-choose-fields'})
      @room.messages.new({:body => @room.category_name, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please choose your project timeline', :room => @room, :user => @room.manager, :msg_type => 'bot-timeline'})
      @room.messages.new({:body => @room.timeline, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please choose the expertise level', :room => @room, :user => @room.manager, :msg_type => 'bot-expertise-level'})
      @room.messages.new({:body => @room.quality, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'What is your budget estimate for this task in USD?', :room => @room, :user => @room.manager, :msg_type => 'bot-budget-estimate'})
      @room.messages.new({:body => @room.budget, :room => @room, :user => @room.user})
      @room.messages.new({:body => 'Please give detailed description of what needs to be done by creating a post, meanwhile I\'ll get this started with our workforce', :room => @room, :user => @room.manager, :msg_type => 'bot-description'})
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
      @room.assign_attributes(room_params)
      website_changed = @room.website_changed?
      total_employee_changed = @room.total_employee_changed?

      if @room.save
        if website_changed
          @room.messages.create(user: @room.manager, msg_type: 'ask-more', body: 'Awesome! Thank you for letting us know what you need. I am now matching your job with one of our many freelancers who will be reaching out shortly. In the meantime, can you please help me get to know you better?') if @room.messages.find_by(msg_type: 'ask-more').nil?
          message = @room.messages.create(user: @room.manager, msg_type: 'add-website', body: 'Please provide your website')
          message.create_attachment(html: "<br/>#{view_context.link_to @room.website, '#', :class => 'mini ui green button custom-padding'}")
        end

        if total_employee_changed
          message = @room.messages.create(user: @room.manager, msg_type: 'add-total-employee', body: 'Great! And how many employees are you?')
          message.create_attachment(html: "<br/>#{view_context.link_to @room.total_employee, '#', :class => 'mini ui green button custom-padding'}'")
        end

        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_messages_seen
    user = current_user.presence || current_freelancer
    messages = user.unseen_messages.where(room: @room)

    respond_to do |format|
      if messages.destroy_all
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
        :website,
        :total_employee,
        :messages_attributes => [:id, :body,
                              :post_attributes => [:id, :content, :title]]
      )
    end
end
