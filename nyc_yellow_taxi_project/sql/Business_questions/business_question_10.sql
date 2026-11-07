/* Which combinations of time, location and 
trip characteristics are useful for operational planning?
*/
----Hourly demand by pickup location
WITH HourlyZoneDemand AS (
    SELECT 
        DATEPART(HOUR, yt.tpep_pickup_datetime) AS pickup_hour,
        yt.PULocationID,
        pickup.zone,
        pickup.Borough,
        COUNT(*) AS total_trips
    FROM analytics.vw_yellow_tripdata_2025_clean AS yt
    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID
    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'
    GROUP BY
        DATEPART(HOUR, yt.tpep_pickup_datetime),
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough
),
HourlyDemandPercentage AS (
SELECT 
    *,
    SUM(total_trips) OVER(PARTITION BY pickup_hour) AS hourly_total_trips,
    total_trips * 100.00 / SUM(total_trips) OVER(PARTITION BY pickup_hour) AS percentage_of_hourly_demand
FROM HourlyZoneDemand
),
RankedZones AS
(
    SELECT
        *,
        RANK() OVER (
            PARTITION BY pickup_hour
            ORDER BY total_trips DESC
        ) AS zone_rank
    FROM HourlyDemandPercentage
)
SELECT *
FROM RankedZones
WHERE zone_rank <= 5
ORDER BY
    pickup_hour,
    zone_rank;

---------2. Demand by weekday and pickup hour
WITH WeekdayHourlyDemand AS (
    SELECT 
        DATENAME(WEEKDAY, yt.tpep_pickup_datetime) AS weekday,
        DATEPART(WEEKDAY, yt.tpep_pickup_datetime) AS weekday_number,
        DATEPART(HOUR, yt.tpep_pickup_datetime) AS pickup_hour,

        COUNT(*) AS total_trips,

        COUNT(DISTINCT CAST(yt.tpep_pickup_datetime AS DATE)) AS observed_dates 
    FROM analytics.vw_yellow_tripdata_2025_clean AS yt 
    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        DATENAME(WEEKDAY, yt.tpep_pickup_datetime),
        DATEPART(WEEKDAY, yt.tpep_pickup_datetime),
        DATEPART(HOUR, yt.tpep_pickup_datetime)
),
averageDailyDemand AS (
    SELECT 
        *,
        CAST(total_trips AS DECIMAL(18,2)) / NULLIF(observed_dates, 0) AS average_daily_trips
    FROM WeekdayHourlyDemand
),
RankWeekdayHours AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY weekday ORDER BY average_daily_trips DESC) AS hour_rank
    FROM averageDailyDemand
)
SELECT 
    weekday,
    weekday_number,
    pickup_hour,
    total_trips,
    observed_dates,
    average_daily_trips,
    hour_rank
FROM RankWeekdayHours
ORDER BY    
    weekday_number,
    hour_rank;

---3. Demand by location and trip distance
WITH TripDistanceBands AS
(
    SELECT
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough,
        yt.trip_distance,

        CASE
            WHEN yt.trip_distance IS NULL THEN 'Missing'
            WHEN yt.trip_distance <= 0 THEN 'Non-positive'
            WHEN yt.trip_distance <= 1 THEN 'Very Short'
            WHEN yt.trip_distance <= 3 THEN 'Short'
            WHEN yt.trip_distance <= 5 THEN 'Medium'
            WHEN yt.trip_distance <= 10 THEN 'Long'
            WHEN yt.trip_distance <= 20 THEN 'Very Long'
            WHEN yt.trip_distance <= 50 THEN 'Extreme'
            WHEN yt.trip_distance <= 100 THEN 'Outlier'
            ELSE 'Suspect'
        END AS distance_category

    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'
),
ZoneDistanceDemand AS (
    SELECT
        PULocationID,
        zone,
        Borough,
        distance_category,
        COUNT(*) AS total_trips,
        AVG(trip_distance) AS average_trip_distance
    FROM TripDistanceBands
    GROUP BY 
        PULocationID,
        Zone,
        Borough,
        distance_category
)
SELECT
    PULocationID,
    Zone,
    Borough,
    distance_category,
    total_trips,

    SUM(total_trips) OVER (
        PARTITION BY PULocationID
    ) AS zone_total_trips,

    CAST(total_trips * 100.0 /
        NULLIF(
            SUM(total_trips) OVER (
                PARTITION BY PULocationID
            ), 0
        )
    AS DECIMAL(10,2)) AS percentage_of_zone_trips,

    average_trip_distance

FROM ZoneDistanceDemand

ORDER BY
    PULocationID,
    total_trips DESC;

----4. demand by location and payment type.
WITH ZonePaymentDemand AS
(
    SELECT
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough,
        yt.payment_type,
        yt.PaymentTypeName,
        COUNT(*) AS total_trips
    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough,
        yt.payment_type,
        yt.PaymentTypeName
)
SELECT 
    *,
    SUM(total_trips) OVER (
        PARTITION BY PULocationID
    ) AS zone_total_trips,

    total_trips * 100.0 /
    SUM(total_trips) OVER (
        PARTITION BY PULocationID
    ) AS percentage_of_zone_demand

FROM ZonePaymentDemand

ORDER BY
    PULocationID,
    total_trips DESC;