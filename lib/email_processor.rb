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
	num = @email.to.tr('^0-9', '')
	room = Room.find num
	room.messages.create({:seen => true, :body => @email.body, :room => room, :user => room.user})
	room.save
    
	puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts @email.subject
    puts @email.body
    puts @email.headers
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  end
end
