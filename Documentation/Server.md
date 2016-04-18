More API Information can be found at http://data.foli.fi

### API Endpoints
The following API endpoints are being used to gather the required data:

- Vehicle monitoring 
`http://data.foli.fi/siri/vm`

- Stop monitoring
`http://data.foli.fi/siri/sm`

- GTFS data (starting point)
`http://data.foli.fi/gtfs`
The GTFS data provides multiple data subpaths, which can be found when looking at the JSON returned from the above url. The full url then needs to be constructed using the latest dataset, following the pattern `'host' + 'gtfspath' + 'latest' + 'subpath'`. An example would look like the following: `http://data.foli.fi/gtfs/v0/20160304-150630/routes`




### Get bus data
To get the bus data, the vehicle monitoring endpoint is called and the response JSON is parsed.
For each bus it provides (among other data) the bus name, geocoordinates, information about the next stop, the one after that, expected arrival time at the next stop and the final destination.


### Get bus stop data
To gather a list of all bus stops and their corresponding identifiers, the stop monitoring url is called and the response JSON is parsed. It contains an entry for each bus stops with name and number.


### Get the full bus route (all upcoming stops) for a bus 
This includes multiple steps:
 - Obtain and save the bus block id ('blockref') from the vehicle monitoring `(http://data.foli.fi/siri/vm)`
 - Request the routes GTFS data `http://data.foli.fi/gtfs/v0/[latest]/routes` (see above). The 'short_name' is the bus number. Check for the matching bus number and save the route_id value
 - Request `http://data.foli.fi/gtfs/v0/[latest]/trips/route/[route_id]` (again replace [latest] and insert the previously saved [route_id])
 - Look through trips, save the tripID of the trip that has the same 'block_id' as the bus
 - Request `http://data.foli.fi/gtfs/v0/[latest]/stop_times/trip/[trip_id]` with the trip_id you just got. This will return all the bus stop ids of the route, which you can match to bus stop names using the stop monitoring `(http://data.foli.fi/siri/sm)`