class FreelancerRatesController < ApplicationController
  before_action :authenticate_user!

  # GET /freelancer_rates
  # GET /freelancer_rates.json
  def index
  end

  # GET /freelancer_rates/1
  # GET /freelancer_rates/1.json
  def show
  end

  # GET /freelancer_rates/1/edit
  def edit
  end

  # POST /freelancer_rates
  # POST /freelancer_rates.json
  def create
    message = Message.find(params[:message_id])
    message.attachment.html =  <<~HTML.squish
      <p><button id="customRateButton-#{params[:message_id]}" class="mini ui green button custom-padding" style="float:right">#{freelancer_rate_params[:rate]}</button><p><br>
    HTML
    message.attachment.save

    @freelancer_rate = FreelancerRate.new(freelancer_rate_params)
    respond_to do |format|
      if @freelancer_rate.save
        message = Message.new({:body => 'The rating for this work is ' + @freelancer_rate.rate.to_s + '.', :room => @freelancer_rate.room, :user => @freelancer_rate.room.manager, :msg_type => 'client-marked-rate'})
        message.save
        message.process_command

        message = Message.new({:body => 'Do you have more work for this freelancer?', :room => @freelancer_rate.room, :user => @freelancer_rate.room.manager, :msg_type => 'bot-ask-continue-work'})
        message.create_attachment html: "<br/>"
        message.attachment.html += <<~HTML.squish
          <button id="customContinueYesButton-#{message.id}" class="mini ui green button custom-padding">Yes</button>
          <button id="customContinueNoButton-#{message.id}" class="mini ui green button custom-padding">No</button>
          <script>
            document.getElementById("customContinueYesButton-#{message.id}").addEventListener('click', function(e) {
              $.ajax({url: "/freelancers_rooms/#{@freelancer_rate.freelancers_room_id}.json", type: "PUT", data: {
                  freelancers_room: {
                    status: 'more_work'
                  },
                  message_id: #{message.id}
                }
              }).done(function() {
                $("#customContinueYesButton-#{message.id}").css("float", "right");
                $("<br><br>").insertAfter("#customContinueYesButton-#{message.id}");
                $("#customContinueYesButton-#{message.id}").attr('id', '');
                $("#customContinueNoButton-#{message.id}").remove();
              });
              e.preventDefault();
            });
            document.getElementById("customContinueNoButton-#{message.id}").addEventListener('click', function(e) {
              $.ajax({url: "/freelancers_rooms/#{@freelancer_rate.freelancers_room_id}.json", type: "PUT", data: {
                  freelancers_room: {
                    status: 'completed'
                  },
                  message_id: #{message.id}
                }
              }).done(function() {
                $("#customContinueNoButton-#{message.id}").css("float", "right");
                $("<br><br>").insertAfter("#customContinueNoButton-#{message.id}");
                $("#customContinueNoButton-#{message.id}").attr('id', '');
                $("#customContinueYesButton-#{message.id}").remove();
                e.preventDefault();
              });
              e.preventDefault();
            });
          </script>
          HTML
        message.attachment.save
        message.process_command
        format.html { redirect_to root_path, notice: 'Rate was successfully created.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @freelancer_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def freelancer_rate_params
      params.require(:freelancer_rate).permit(:user_id, :freelancer_id, :room_id, :freelancers_room_id, :rate)
    end
end
