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
	
	num = @email.to.to_s.tr('^0-9', '')
	room = Room.find num
	room.messages.create({:seen => true, :body => @email.body, :room => room, :user => room.user})
	room.save
  end
end
