FactoryBot.define do
  factory :google_calendar_setting do
    user { nil }
    monday { false }
    tuesday { false }
    wednesday { false }
    thursday { false }
    friday { false }
    saturday { false }
    sunday { false }
    start_time { "2022-08-01 09:56:11" }
    end_time { "2022-08-01 09:56:11" }
  end
end
