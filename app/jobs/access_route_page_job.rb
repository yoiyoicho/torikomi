class AccessRoutePageJob < ApplicationJob
  require 'typhoeus'
  queue_as :default

  def perform
    url = 'https://torikomi.herokuapp.com'
    response = Typhoeus::Request.get(url)
  end

end