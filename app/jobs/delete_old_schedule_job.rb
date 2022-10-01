class DeleteOldSchedulesJob < ApplicationJob
  def perform
    Schedule.where("end_time < ?", 1.month.ago.in_time_zone).each do |old_schedule|
      old_schedule.destroy!
    end
  end
end