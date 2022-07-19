namespace :send_line_message do
  desc 'LINEメッセージを送信する'
	task send_test_message: :environment do
		request = LineMessagingApi.new
    request.send_broadcast_message('test message')
	end
end
