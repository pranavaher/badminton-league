FactoryBot.define do
  factory :player do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    country { create(:country) }

    trait :with_wins do
      after(:create) do |player|
        opponent = create(:player)
        create(:match, player_a: player, player_b: opponent, winner: player)
      end
    end

    trait :with_losses do
      after(:create) do |player|
        opponent = create(:player)
        create(:match, player_a: player, player_b: opponent, winner: opponent)
      end
    end
  end
end
