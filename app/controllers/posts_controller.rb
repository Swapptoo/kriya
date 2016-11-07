class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]
  before_action :set_goomp, only: [:new]
  before_action :authenticate!, except: [:public]
  respond_to :html, :json

  layout 'pages', if: -> { action_name == 'public' }
  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find params[:id]
    respond_modal_with @post and return
  end

  def like
    @post = Post.find params[:id]
    @post.liked_by current_user
    @post.reload
  end

  # GET /posts/new
  def new
    @post = Post.new
    # render layout: "pages"
    respond_modal_with @post and return
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find params[:id]
    respond_modal_with @post and return
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.new(post_params)
    @post.goomp = Goomp.friendly.find params[:goomp_id] if params[:goomp_id].present?
    if @post.save
      @message = Message.new
      @message.post = @post
      @room = Room.find request.referer.split('/').last
      last_message = @room.messages.last

      @message.room = @room
      @message.user = current_user

      @message.save
      @message.process_command

      if last_message.bot_description?
        message = @room.messages.create(seen: true, body: 'Thanks for your detailed write up. We are assigning someone who can get this done faster. To stay upto date, feel free to add this task as Slack channel', room: @room, user: @room.manager, msg_type: 'slack-integration')
        message.create_attachment(
          message: @message,
          html: slack_integration_html
        )
      end

      respond_modal_with @post, location: request.referer and return
    end
    # respond_to do |format|
    #   if @post.save
    #     debugger
    #     format.html do
    #       # It's a full-size story
    #       debugger
    #       if @post.content
    #         @post.generate_link_for_story!
    #         redirect_to @post.goomp, notice: 'Post was successfully created.'
    #       else
    #         redirect_back fallback_location: @post.goomp, notice: 'Post was successfully created.'
    #       end
    #     end
    #     format.json { render :show, status: :created, location: @post }
    #     format.js
    #   else
    #     format.html { render :new }
    #     format.json { render json: @post.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      respond_modal_with @post, location: request.referer and return
    end
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def public
    @post = Post.find_by(token: params[:token])

    redirect_to room_path(@post.room) and return if current_freelancer.present?
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = current_user.posts.find(params[:id])
    end

    def set_goomp
      @goomp = Goomp.friendly.find(params[:goomp_id]) if params[:goomp_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(
        :title,
        :body,
        :content,
        :goomp_id,
        :subtopic_id,
        :link_title,
        :link_description,
        :link_image,
        :link_video,
        :link_url,
      )
    end

    def slack_integration_html
      "</br>#{view_context.link_to 'Add to Slack', slack_integration_url, class: 'mini ui green button custom-padding' } #{view_context.link_to 'No, Thanks', reject_slack_integration_room_path(@room), class: 'mini ui green button custom-padding' }"
    end

    def slack_integration_url
      "https://slack.com/oauth/authorize?scope=incoming-webhook,channels:write,chat:write:bot&client_id=#{Rails.application.secrets.slack_app_id}"
    end
end
