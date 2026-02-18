FactoryBot.define do
  factory :match do
    name { "Match #{Random.rand(1..1000)}" }
    player_a { create(:player) }
    player_b { create(:player) }
    venue { create(:country) }
    scheduled_at { 2.days.from_now }

    trait :scheduled_in_past do
      scheduled_at { 2.days.ago }
    end

    trait :with_winner do
      winner { player_a }
      loser { player_b }
      scheduled_at { 2.days.ago }
    end

    trait :pending do
      winner { nil }
      loser { nil }
    end

    trait :auto_decide do
      auto_decide { true }
    end
  end
end
