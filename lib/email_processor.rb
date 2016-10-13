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
	room = Room.find num
	body = @email.body
	lines = body.split("\n")
	body = ""
	lines.each do |line|
		if line.include? "Kriya Notification" then 
			break
		end
		body += line + "\n"
	end
	room.messages.create({:seen => false, :body => body, :room => room, :user => room.user})
	@email.attachments.each do |attachment|
		room.messages.create({:seen => false, :body => '', :room => room, :user => room.user, :image => attachment})
	end
	room.save
	
	ActionCable.server.broadcast(
        "rooms:#{room.id}:messages",
        message: MessagesController.render(
          partial: 'messages/message',
          locals: {
            message: room.messages.last, user: room.user
          }
        ),
        room_id: room.id,
      )
  end
end
