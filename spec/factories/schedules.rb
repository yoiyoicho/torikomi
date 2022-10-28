FactoryBot.define do
  factory :schedule do
    association :user, :default
    sequence(:title) { |n| "title_#{n}" }
    body { 'body' }
    start_time { 1.day.since.beginning_of_day.in_time_zone }
    end_time { 1.day.since.beginning_of_day.in_time_zone + 1.hour }
    job_id { 'job_id' }
    status { :to_be_sent }

    trait :default do
      resource_type { :default }
    end

    trait :google do
      resource_type { :google }
      i_cal_uid { 'i_cal_uid' }
    end
  end
end
