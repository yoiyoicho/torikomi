FactoryBot.define do
  factory :setting do
    user { nil }
    message_option { 1 }
    message { "MyString" }
    notification_time { 1 }
  end
end
