# frozen_string_literal: true

require "faraday"
require "json"
require "zlib"
require "byebug"
require "iso8601"

module ComThetrainline
  class Client
    attr_accessor :from, :to, :departure_at

    def initialize(from, to, departure_at)
      @from = from
      @to = to
      @departure_at = departure_at
    end

    def call
      validate_parameters
      perform_request
    end

    def validate_parameters
      raise ArgumentError, "'from' parameter cannot be nil" if @from.nil?
      raise ArgumentError, "'to' parameter cannot be nil" if @to.nil?
      raise ArgumentError, "'departure_at' must be a DateTime object" unless @departure_at.is_a?(DateTime)

      return unless @departure_at <= DateTime.now.to_date

      raise ArgumentError,
            "'departure_at' must be greater or equal to current Date"
    end

    private

    def perform_request
      url = "https://www.thetrainline.com/api/journey-search/"

      response = Faraday.post(url, payload.to_json, headers)

      if response.success?
        puts "API request successful"
        process(response.body)
      else
        puts "API request failed with status #{response.status}"
        puts "Response body: #{response.body}"
      end
    end

    def process(body)
      results = JSON.parse(Zlib::GzipReader.new(StringIO.new(body)).read)
      journeys = results["data"]["journeySearch"]["journeys"]
      @locations = results["data"]["locations"]
      @legs = results["data"]["journeySearch"]["legs"]
      @fares = results["data"]["journeySearch"]["fares"]
      @transport_modes = results["data"]["transportModes"]
      @alternatives = results["data"]["journeySearch"]["alternatives"]
      @sections = results["data"]["journeySearch"]["sections"]
      @fare_types = results["data"]["fareTypes"]

      journeys.map do |_journey_id, journey|
        build_segment(journey)
      end
    end

    def build_segment(journey)
      first_leg = @legs[journey["legs"].first]
      last_leg = @legs[journey["legs"].last]
      departure_location = @locations[first_leg["departureLocation"]]
      arrival_location = @locations[last_leg["arrivalLocation"]]
      {
        departure_station: departure_location["name"],
        departure_at: DateTime.parse(first_leg["departAt"]),
        arrival_station: arrival_location["name"],
        arrival_at: DateTime.parse(last_leg["arriveAt"]),
        service_agencies: ["thetrainline"], # this is hardcoded as the offer is always from thetrainline
        duration_in_minutes: duration_to_minutes(journey["duration"]),
        changeovers: calculate_changeovers(journey),
        products: transport_modes(journey["legs"]),
        fares: build_fares(journey)
      }
    end

    def build_fares(journey)
      journey["sections"].map do |section_id|
        build_single_fare(@sections[section_id])
      end
    end

    def build_single_fare(section)
      alternative = @alternatives[section["alternatives"].first]
      fare = @fares[alternative["fares"].first]

      {
        name: fare_name(fare),
        price_in_cents: alternative["price"]["amount"],
        currency: alternative["price"]["currencyCode"],
        comfort_class: comfort_class(fare["fareLegs"].first["travelClass"]["id"])
      }
    end

    def comfort_class(_travel_class_id)
      # TODO: find the relation between travel_class_id and comfort class
      # For now this will always return 1 until we found the relation
      1
    end

    def fare_name(fare)
      @fare_types[fare["fareType"]]["name"]
    end

    def transport_modes(legs)
      legs.map do |leg|
        @transport_modes[@legs[leg]["transportMode"]]["mode"]
      end
    end

    def calculate_changeovers(journey)
      journey["legs"].count - 1
    end

    def duration_to_minutes(duration_str)
      duration = ISO8601::Duration.new(duration_str)
      total_minutes = duration.to_seconds / 60
      total_minutes.to_i
    end

    def headers
      {
        "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0",
        "Accept" => "application/json",
        "Accept-Language" => "de-DE",
        "Accept-Encoding" => "gzip, deflate, br",
        "Referer" => "https://www.thetrainline.com/book/results?origin=urn%3Atrainline%3Ageneric%3Aloc%3A182gb&destination=urn%3Atrainline%3Ageneric%3Aloc%3A4916&outwardDate=2024-02-15T06%3A00%3A00&outwardDateType=departAfter&journeySearchType=single&passengers%5B0%5D=1991-02-07%7Cpid-0&directSearch=false",
        "Content-Type" => "application/json",
        "x-version" => "4.35.28061"
      }
    end

    def payload # rubocop:disable Metrics/MethodLength
      {
        passengers: [
          {
            id: "pid-0",
            dateOfBirth: "1991-02-07",
            cardIds: []
          }
        ],
        isEurope: true,
        cards: [],
        transitDefinitions: [
          {
            direction: "outward",
            origin: from,
            destination: to,
            journeyDate: {
              type: "departAfter",
              time: departure_at.iso8601
            }
          }
        ],
        type: "single",
        maximumJourneys: 5,
        includeRealtime: true,
        transportModes: ["mixed"],
        directSearch: false,
        composition: %w[through interchangeSplit]
      }
    end
  end
end
