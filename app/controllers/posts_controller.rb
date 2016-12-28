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

      @message.room = @room
      @message.user = current_user

      @message.save
      @message.process_command

      respond_modal_with @post, location: request.referer and return
    end
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
    token = params[:token].split('-').last
    @post = Post.find_by(token: token)

    redirect_to room_path(@post.room) and return if user_can_access_room? || freelancer_can_access_room?
  end

  private

  def user_can_access_room?
    user_signed_in? && (current_user.rooms.include?(@post.room) || current_user.manager?)
  end

  def freelancer_can_access_room?
    freelancer_signed_in? && current_freelancer.available_rooms.include?(@post.room)
  end

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
end
