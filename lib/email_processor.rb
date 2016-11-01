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
	if @email.to.first[:token].include? "manager" then
		sender = room.user
	else
		sender = room.manager
	end
	lines = body.split("\n")
	body = ""
	lines.each do |line|
		if line.include? "Kriya Bot" then
			break
		end
		body += line + "\n"
	end
	room.messages.create({:seen => false, :body => body, :room => room, :user => sender})
	@email.attachments.each do |attachment|
		room.messages.create({:seen => false, :body => '', :room => room, :user => sender, :image => attachment})
	end
	room.save

	ActionCable.server.broadcast(
        "rooms:#{room.id}:messages",
        message: MessagesController.render(
          partial: 'messages/message',
          locals: {
            message: room.messages.last, user: sender
          }
        ),
        room_id: room.id,
      )
  end
end
