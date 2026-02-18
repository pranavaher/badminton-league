FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "TestPassword123!" }
    password_confirmation { "TestPassword123!" }
  end
end
