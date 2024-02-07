# ComThetrainline

Sample client to get prices from Thetrainline

## Installation

To use ComThetrainline, follow these simple steps:

1. Clone the repository:
```
git clone <repository-url>
```

2. Navigate to the project directory:
```
cd com_thetrainline
```

3. Start the application using Docker Compose:
```
docker-compose up
```

## Usage

To test the functionality of the ComThetrainline client, you can interact with it through the Docker container and an interactive Ruby (irb) session. Follow these steps:

1. Enter the Docker container:
```
docker-compose exec com_thetrainline /bin/bash
```

2. Install gems
```
bundle
```

3. Start an interactive Ruby session:
```
irb
```

4. Inside the irb console, call the ComThetrainline module:
```
ComThetrainline.find("urn:trainline:generic:loc:182gb", "urn:trainline:generic:loc:34614", DateTime.now) # London to Munich Airport
```

## Example Result
The result array will look similar to the following:
```
[
  {
    :departure_station=>"London St-Pancras",
    :departure_at=>#<DateTime: 2024-02-07T12:31:00+00:00>,
    :arrival_station=>"München Flughafen Terminal",
    :arrival_at=>#<DateTime: 2024-02-08T00:08:00+01:00>,
    :service_agencies=>["thetrainline"],
    :duration_in_minutes=>637,
    :changeovers=>3,
    :products=>["train", "train", "train", "train"],
    :fares=>[
      {:name=>"Business Premier", :price_in_cents=>325, :currency=>"GBP", :comfort_class=>1},
      {:name=>"Flexpreis Europa", :price_in_cents=>151, :currency=>"GBP", :comfort_class=>1}
    ]
  },
  # Additional results...
]
```
