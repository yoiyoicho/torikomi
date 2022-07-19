namespace :send_line_message do
  desc 'LINEメッセージを送信する'
	task send_test_message: :environment do
		controller = LineMessagingApiController.new
    controller.send_broadcast_message('test message')
	end
end
