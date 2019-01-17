module Gitlab
  module Projects
    class EventsController < ActionController::Base
      def create
        render status: :ok
      end
    end
  end
end
