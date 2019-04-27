require 'csv'
require 'faker'
require 'as-duration'
require 'awesome_print'

drivers = []
passengers = []

passenger_csv = CSV.open('./passengers.csv', 'w+', write_headers: true, headers: ['id', 'name', 'phone_num'])
150.times do |id|
  name = Faker::Name.name
  phone_num = Faker::PhoneNumber.cell_phone

  passenger_hash = { 'id' => id + 1, 'name' => name, 'phone_num' => phone_num }

  passenger_csv << passenger_hash
  passengers << passenger_hash
end


driver_csv = CSV.open('./drivers.csv', 'w+', write_headers: true, headers: ['id', 'name', 'vin', 'status'])
30.times do |id|
  driver_hash = {
    'id' => id + 1,
    'name' => Faker::Artist.name,
    'vin' => Faker::Vehicle.vin,
    'status' => rand(0..10) < 3 ? :UNAVAILABLE : :AVAILABLE
  }
  driver_csv << driver_hash
  drivers << driver_hash
end

# At least a few drivers should have no trips
drivers_with_trips = drivers.reject { |d| d['id'] % 5 == 1 }

trips_csv = CSV.open('./trips.csv', 'w+', write_headers: true, headers: ['id', 'driver_id', 'passenger_id', 'start_time', 'end_time', 'cost', 'rating'])
600.times do |id|
  driver = drivers_with_trips.sample['id']
  passenger = passengers.sample['id']

  start_time = Faker::Time.between(3.months.ago, Date.today, :all)
  end_time = start_time + rand(180..3600)
  cost = rand(5..30)
  rating = rand(1..5)
  trip_hash = {
    'id' => id + 1,
    'driver_id' => driver,
    'passenger_id' => passenger,
    'start_time' => start_time,
    'end_time' => end_time,
    'cost' => cost,
    'rating' => rating
  }
  trips_csv << trip_hash
end
