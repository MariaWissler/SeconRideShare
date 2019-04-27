require_relative "spec_helper"

TEST_DATA_DIRECTORY = "specs/test_data"

describe "TripDispatcher class" do
  def build_test_dispatcher
    return RideShare::TripDispatcher.new(
             directory: TEST_DATA_DIRECTORY,
           )
  end

  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = build_test_dispatcher
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = build_test_dispatcher
      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      # expect(dispatcher.drivers).must_be_kind_of Array
    end

    it "loads the development data by default" do
      # Count lines in the file, subtract 1 for headers
      trip_count = %x{wc -l 'support/trips.csv'}.split(" ").first.to_i - 1

      dispatcher = RideShare::TripDispatcher.new

      expect(dispatcher.trips.length).must_equal trip_count
    end
  end

  describe "passengers" do
    describe "find_passenger method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect { @dispatcher.find_passenger(0) }.must_raise ArgumentError
      end

      it "finds a passenger instance" do
        passenger = @dispatcher.find_passenger(2)
        expect(passenger).must_be_kind_of RideShare::Passenger
      end
    end

    describe "Passenger & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads passenger information into passengers array" do
        first_passenger = @dispatcher.passengers.first
        last_passenger = @dispatcher.passengers.last

        expect(first_passenger.name).must_equal "Passenger 1"
        expect(first_passenger.id).must_equal 1
        expect(last_passenger.name).must_equal "Passenger 8"
        expect(last_passenger.id).must_equal 8
      end

      it "connects trips and passengers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.passenger).wont_be_nil
          expect(trip.passenger.id).must_equal trip.passenger_id
          expect(trip.passenger.trips).must_include trip
        end
      end
    end
  end

  describe "drivers" do
    describe "find_driver method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
      end

      it "finds a driver instance" do
        driver = @dispatcher.find_driver(2)
        expect(driver).must_be_kind_of RideShare::Driver
      end
    end

    describe "Driver & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads driver information into drivers array" do
        first_driver = @dispatcher.drivers.first
        last_driver = @dispatcher.drivers.last

        expect(first_driver.name).must_equal "Driver 1 (unavailable)"
        expect(first_driver.id).must_equal 1
        expect(first_driver.status).must_equal :UNAVAILABLE
        expect(last_driver.name).must_equal "Driver 3 (no trips)"
        expect(last_driver.id).must_equal 3
        expect(last_driver.status).must_equal :AVAILABLE
      end

      it "connects trips and drivers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.driver).wont_be_nil
          expect(trip.driver.id).must_equal trip.driver_id
          expect(trip.driver.trips).must_include trip
        end
      end
    end
    describe "trip_request method" do
      before do
        @dispatcher = build_test_dispatcher
      end
      it "creates a new instance of a trip" do
        new_trip = @dispatcher.request_trip(1)

        expect(new_trip).must_be_kind_of RideShare::Trip
      end

      it "updates the trip list for the passenger" do
        passenger = @dispatcher.find_passenger(1)
        number_of_passenger_trips = passenger.trips.count

        new_trip = @dispatcher.request_trip(1)
        puts new_trip.driver.name

        expect(passenger.trips.count).must_equal(number_of_passenger_trips + 1)
      end

      it "updates the trip list for the driver" do
        driver = @dispatcher.drivers[1]
        number_of_driver_trips = driver.trips.count

        new_trip = @dispatcher.request_trip(1)

        expect(driver.id).must_equal(new_trip.driver.id)
        expect(driver.trips.count).must_equal(number_of_driver_trips + 1)
      end

      it "selects the first available driver" do
        first_available_driver = ""
        @dispatcher.drivers.each do |driver|
          if driver.status == :AVAILABLE
            first_available_driver = driver
            break
          end
        end

        new_trip = @dispatcher.request_trip(1)
        expect(new_trip.driver.id).must_equal(first_available_driver.id)
      end

      it "returns a message if there are no available drivers" do
        100.times do
          @dispatcher.request_trip(2)
        end

        new_trip = @dispatcher.request_trip(2)
        expect(new_trip).must_equal("Sorry, no available drivers.  Try again later!")
      end
    end
  end
end
