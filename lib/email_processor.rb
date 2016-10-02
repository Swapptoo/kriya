class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    # all of your application-specific code here - creating models,
    # processing reports, etc
    # @room.messages.create({:seen => true, :body => 'Please choose one your project timeline', :room => @room, :user => @room.manager})

    # @user = User.find_by_email(@email.from[:email])
    #
    #
    #
    # # here's an example of model creation
    # user.posts.create!(
    #   subject: @email.subject,
    #   body: @email.body
    # )
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts @email.subject
    puts @email.body
    puts @email.headers
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  end

  private

  def room
    # return @user.joined_rooms.first if @user.joined_rooms.count == 1
  end
end
