require_relative "csv_record"

module RideShare
  class Driver < CsvRecord
    attr_reader :name, :vin, :status, :trips

    def initialize(id:, name:, vin:, status: :AVAILABLE, trips: nil)
      super(id)

      @name = name
      @vin = vin
      @status = status.to_sym
      @trips = trips || []

      raise ArgumentError, "Invalid VIN: #{vin}" unless @vin.length == 17
    end

    def add_trip(trip)
      @trips << trip
    end

    def average_rating
      if @trips.empty?
        return 0
      else
        average_rating = 0
        @trips.each do |trip|
          if trip.end_time != nil
            average_rating += trip.rating
          end
        end
      end

      average_rating /= @trips.length
      return average_rating.to_f.round(2)
    end

    def total_revenue
      if @trips.empty?
        return 0
      else
        total_revenue = 0
        @trips.each do |trip|
          if trip.end_time != nil
            unless trip.cost < 1.65
              total_revenue += (trip.cost - 1.65)
            end
          end
        end
      end

      total_revenue *= 0.8
      return total_revenue.to_f.round(2)
    end

    def assign_new_trip(new_trip)
      add_trip(new_trip)
      @status = :UNAVAILABLE
    end

    private

    def self.from_csv(record)
      new(
        id: record[:id],
        name: record[:name],
        vin: record[:vin],
        status: record[:status],
      )
    end
  end
end
