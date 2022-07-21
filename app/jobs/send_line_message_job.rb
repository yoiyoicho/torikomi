class SendLineMessageJob < ApplicationJob
  queue_as :default

  def perform(*arg)
    controller = LineMessagingApiController.new
    controller.send_push_message_by_schedule_id(arg[0])
  end
end
