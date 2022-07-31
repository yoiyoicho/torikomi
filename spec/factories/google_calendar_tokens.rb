FactoryBot.define do
  factory :google_calendar_token do
    user { nil }
    access_token { "MyString" }
    refresh_token { "MyString" }
  end
end
