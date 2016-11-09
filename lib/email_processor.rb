class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
  	puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts @email.subject
    puts @email.body
    puts @email.headers
  	puts @email.to
  	puts @email.from
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@"

  	num = @email.to.first[:token].tr('^0-9', '')

  	room = Room.find(num)
    email = @email.from[:email]
    body = @email.body

    user = User.find_by(email: email)
    user = Freelancer.find_by(email: email) if user.nil?

    message_params = { body: body }

    if room.accepted_freelancers.include?(user)
      message_params[:freelancer] = user
    else
      message_params[:user] = user
    end

  	room.messages.create(message_params)

  	@email.attachments.each do |attachment|
      message_params[:image] = attachment
      message_params[:body]  = ''
  		room.messages.create(message_params)
  	end

  	room.save

  	ActionCable.server.broadcast(
      'rooms:#{room.id}:messages',
      message: MessagesController.render(
        partial: 'messages/message',
        locals: {
          message: room.messages.last, user: sender
        }
      ),
      room_id: room.id
    )
  end
end
