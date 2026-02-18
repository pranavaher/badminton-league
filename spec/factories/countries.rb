FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }

    trait :india do
      name { 'India' }
    end

    trait :usa do
      name { 'USA' }
    end

    trait :uk do
      name { 'UK' }
    end
  end
end
