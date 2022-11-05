FactoryBot.define do
  factory :line_user do
    sequence(:line_user_id) { |n| "line_user_id_#{n}" }
    sequence(:display_name) { |n| "line_user_#{n}" }
  end
end
