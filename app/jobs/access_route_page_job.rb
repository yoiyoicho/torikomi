class AccessRoutePageJob < ApplicationJob
  require 'typhoeus'
  queue_as :default

  def perform
    url = 'https://www.torikomi.net'
    response = Typhoeus::Request.get(url)
  end

end