----Q2. Which pickup and drop-off zones account for the greatest trip activity?
---pickupzones account for the greatest trip activity
CREATE OR ALTER VIEW analytics.vw_q2_pickup_zone_demand
AS
WITH pickupzone_activity AS
(
    SELECT
        yt.PULocationID,
        pickup.Zone AS pickup_zone,
        pickup.Borough AS pickup_borough,
        COUNT(*) AS total_trips

    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough
),

annual_demand AS
(
    SELECT SUM(total_trips) AS annual_total_trips
    FROM pickupzone_activity
)

SELECT
    p.PULocationID,
    p.pickup_zone,
    p.pickup_borough,
    p.total_trips,

    CAST(
        p.total_trips * 100.0 /
        NULLIF(a.annual_total_trips, 0)
        AS DECIMAL(10,4)
    ) AS percentage_of_trips

FROM pickupzone_activity AS p
CROSS JOIN annual_demand AS a;

---dropoff_zones account for the greatest trip activity
CREATE OR ALTER VIEW analytics.vw_q2_dropoff_zone_demand
AS
WITH dropoff_zone_activity AS
(
    SELECT
        yt.DOLocationID,
        dropoff.Zone AS dropoff_zone,
        dropoff.Borough AS dropoff_borough,
        COUNT(*) AS total_trips

    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS dropoff
        ON yt.DOLocationID = dropoff.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        yt.DOLocationID,
        dropoff.Zone,
        dropoff.Borough
),

annual_demand AS
(
    SELECT
        SUM(total_trips) AS annual_total_trips
    FROM dropoff_zone_activity
)

SELECT
    d.DOLocationID,
    d.dropoff_zone,
    d.dropoff_borough,
    d.total_trips,

    CAST(
        d.total_trips * 100.0 /
        NULLIF(a.annual_total_trips, 0)
        AS DECIMAL(10,4)
    ) AS percentage_of_trips

FROM dropoff_zone_activity AS d

CROSS JOIN annual_demand AS a;

----top origin–destination pairs
CREATE OR ALTER VIEW analytics.vw_q2_origin_destination_demand
AS
WITH origin_destination_pairs AS
(
    SELECT
        yt.PULocationID,
        pickup.Borough AS PickupBorough,
        pickup.Zone AS PickupZone,

        yt.DOLocationID,
        dropoff.Borough AS DropoffBorough,
        dropoff.Zone AS DropoffZone,

        COUNT(*) AS TotalTrips

    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID

    LEFT JOIN analytics.taxi_zone_lookup AS dropoff
        ON yt.DOLocationID = dropoff.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        yt.PULocationID,
        pickup.Borough,
        pickup.Zone,
        yt.DOLocationID,
        dropoff.Borough,
        dropoff.Zone
),

annual_demand AS
(
    SELECT
        SUM(TotalTrips) AS annual_total_trips
    FROM origin_destination_pairs
)

SELECT
    od.PULocationID,
    od.PickupBorough,
    od.PickupZone,
    od.DOLocationID,
    od.DropoffBorough,
    od.DropoffZone,
    od.TotalTrips,

    CAST(
        od.TotalTrips * 100.0 /
        NULLIF(a.annual_total_trips, 0)
        AS DECIMAL(16,4)
    ) AS count_percentage

FROM origin_destination_pairs AS od

CROSS JOIN annual_demand AS a;

