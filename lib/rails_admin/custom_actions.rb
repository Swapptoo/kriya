module RailsAdmin
  module Config
    module Actions
      # common config for custom actions
      class Customaction < RailsAdmin::Config::Actions::Base
        register_instance_option :member do  #  this is for specific record
          true
        end
        register_instance_option :pjax? do
          false
        end
        register_instance_option :visible? do
          authorized?     # This ensures the action only shows up for the right class
        end
      end

      class UpdateUserStatus < Customaction
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :only do
          User
        end
        register_instance_option :link_icon do
          'fa fa-paper-plane' # use any of font-awesome icons
        end
        register_instance_option :http_methods do
          [:get, :post]
        end
        register_instance_option :controller do
          Proc.new do
            # call model.method here
            @object.update_status
            flash[:notice] = "Updated status on #{@object.first_name} #{@object.last_name}"
            redirect_to back_or_index
          end
        end
      end
    end
  end
end