class DeleteDraftSchedulesJob < ApplicationJob

  queue_as :default

  def perform
    Schedule.draft.where("end_time < ?", Time.zone.now).each do |draft_schedule|
      draft_schedule.destroy!
    end
  end

end