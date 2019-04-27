
require_relative "spec_helper"

describe "Passenger class" do
  describe "Passenger instantiation" do
    before do
      @passenger = RideShare::Passenger.new(reservation_id: 1, name: "Smithy", phone_number: "353-533-5334")
    end

    it "is an instance of Passenger" do
      expect(@passenger).must_be_kind_of RideShare::Passenger
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::Passenger.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@passenger.trips).must_be_kind_of Array
      expect(@passenger.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@passenger).must_respond_to prop
      end

      expect(@passenger.id).must_be_kind_of Integer
      expect(@passenger.name).must_be_kind_of String
      expect(@passenger.phone_number).must_be_kind_of String
      expect(@passenger.trips).must_be_kind_of Array
    end
  end

  describe "trips property" do
    before do
      # TODO: you'll need to add a driver at some point here.
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: [],
      )
      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: "2016-08-08",
        end_time: "2016-08-09",
        rating: 5,
        driver_id: 1,
      )

      @passenger.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @passenger.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's passenger id" do
      @passenger.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end

  describe "net_expenditures" do
    before do
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: [],
      )
      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: "2018-12-27 02:39:05 -0800",
        end_time: "2018-12-27 03:38:08 -0800",
        cost: 15,
        rating: 5,
        driver_id: 1,
      )

      @passenger.add_trip(trip)

      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: "2018-12-27 04:20:08 -0800",
        end_time: "2018-12-27 05:00:08 -0800",
        cost: 12,
        rating: 4,
        driver_id: 1,
      )

      @passenger.add_trip(trip)
    end
    it "calculates total amount of money spent by one passenger" do
      total_cost = @passenger.net_expenditures

      expect(total_cost).must_equal 27
    end

    it "returns 0 dollars if there are no trips" do
      @passenger.trips.clear

      total_cost = @passenger.net_expenditures

      expect(total_cost).must_equal 0
    end
  end

  describe "total_time" do
    before do
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: [],
      )
      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: "2018-12-27 02:39:05 -0800",
        end_time: "2018-12-27 03:38:08 -0800",
        cost: 15,
        rating: 5,
        driver_id: 1,
      )

      @passenger.add_trip(trip)

      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: "2018-12-27 04:20:08 -0800",
        end_time: "2018-12-27 05:00:08 -0800",
        cost: 12,
        rating: 4,
        driver_id: 1,
      )

      @passenger.add_trip(trip)
    end

    it "calculates total amount of time spent by one passenger" do
      total_time = @passenger.total_time_spent

      expect(total_time).must_equal 5943.0
    end

    it "returns 0 seconds if there are no trips" do
      @passenger.trips.clear

      total_time = @passenger.total_time_spent

      expect(total_time).must_equal 0
    end
  end
end
