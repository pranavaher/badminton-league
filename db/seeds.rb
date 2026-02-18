# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

countries = [
  'India',
  'USA',
  'UK',
  'Canada',
  'Australia',
  'Japan',
  'China',
  'Germany',
  'France',
  'Brazil',
  'Mexico',
  'South Africa',
  'Indonesia',
  'Malaysia',
  'Thailand',
  'Singapore',
  'Pakistan',
  'Bangladesh',
  'Sri Lanka',
  'Nepal'
].each do |name|
  Country.find_or_create_by!(name: name)
end

puts "Seeded #{Country.count} countries."
