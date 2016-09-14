class RoomPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.project_manager?
        scope.all
      else
        scope.joined_rooms
      end
    end
  end
end