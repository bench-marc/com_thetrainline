# frozen_string_literal: true

RSpec.describe ComThetrainline::Client do
  let(:client) do
    described_class.new("urn:trainline:generic:loc:182gb", "urn:trainline:generic:loc:34614",
                        DateTime.parse("2024-02-08T11:44:26+00:00"))
  end

  around do |example|
    VCR.use_cassette "api_request" do
      example.run
    end
  end

  describe "#call" do
    context "when the API request is successful" do
      it "returns an array of results" do
        expect(client.call).to be_an(Array)
      end

      it "contains correct attributes" do
        result = client.call
        expect(result.first).to include(:departure_station, :departure_at, :arrival_station, :arrival_at,
                                        :service_agencies, :duration_in_minutes, :changeovers, :products, :fares)
        expect(result.first[:fares]).to be_an(Array)
        expect(result.first[:fares].first).to include(:name, :price_in_cents, :currency, :comfort_class)
      end
    end

    context "when the API request fails" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(instance_double(Faraday::Response,
                                                                                                success?: false, status: 500, body: "Internal Server Error"))
      end

      it "prints an error message" do
        expect do
          client.call
        end.to output("API request failed with status 500\nResponse body: Internal Server Error\n").to_stdout
      end
    end
  end

  describe "#validate_parameters" do
    context "with valid parameters" do # TODO: remove?
      it "does not raise an error" do
        client = described_class.new("London", "Paris", DateTime.now)
        expect { client.validate_parameters }.not_to raise_error
      end
    end

    context 'with nil "from" parameter' do
      it "raises an ArgumentError" do
        client = described_class.new(nil, "Paris", DateTime.now)
        expect { client.validate_parameters }.to raise_error(ArgumentError, "'from' parameter cannot be nil")
      end
    end

    context 'with nil "to" parameter' do
      it "raises an ArgumentError" do
        client = described_class.new("London", nil, DateTime.now)
        expect { client.validate_parameters }.to raise_error(ArgumentError, "'to' parameter cannot be nil")
      end
    end

    context 'with non-DateTime "departure_at" parameter' do
      it "raises an ArgumentError" do
        client = described_class.new("London", "Paris", "invalid_datetime")
        expect { client.validate_parameters }.to raise_error(ArgumentError, "'departure_at' must be a DateTime object")
      end
    end

    context 'with "departure_at" parameter not greater than Date.now' do
      it "raises an ArgumentError" do
        invalid_datetime = DateTime.now - 1 # Set 'departure_at' to a past date
        client = described_class.new("London", "Paris", invalid_datetime)
        expect do
          client.validate_parameters
        end.to raise_error(ArgumentError, "'departure_at' must be greater or equal to current Date")
      end
    end
  end
end
