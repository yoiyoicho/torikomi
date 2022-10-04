class DeleteOldLinkTokensJob < ApplicationJob

  queue_as :default

  def perform
    LinkToken.where("created_at < ?", 1.days.ago.in_time_zone).each do |old_link_token|
      old_link_token.destroy!
    end
  end

end