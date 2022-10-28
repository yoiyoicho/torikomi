FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    role { :general }

    trait :default do
      password { 'password' }
      password_confirmation { 'password' }
      login_type { :default }
    end

    trait :google do
      login_type { :google }
    end
  end
end
