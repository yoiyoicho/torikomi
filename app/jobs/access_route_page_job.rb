class AccessRoutePageJob < ApplicationJob
  require 'typhoeus'
  def perform
    url = 'https://torikomi.herokuapp.com'
    response = Typhoeus::Request.get(url)
  end
end