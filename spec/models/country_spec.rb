require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:players) }
    it { is_expected.to have_many(:matches) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'creation' do
    it 'creates a country with a name' do
      country = create(:country, name: 'India')
      expect(country.name).to eq('India')
    end

    it 'prevents duplicate country names' do
      create(:country, name: 'USA')
      duplicate = build(:country, name: 'USA')
      expect(duplicate).not_to be_valid
    end
  end
end
