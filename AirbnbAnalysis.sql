/*
                                  Airbnb Analysis
                                  By Allen Xu

      

                                     Introduction
-Analysis: Exploring Airbnb guest data to get interesting insights and to answer business questions.
-Tools: MySQL (table structure as shown in the tutorial below)

 */
########################################################################################################################


use airbnb;
#                                     Questions
# 1: How many unique listings are provided in the calendar table?

select count(distinct listing_id)
from calendar;     -- Answer 3585 unique listings


# 2: How many calendar years do the calendar table span?
# (Expected output: e.g., this table has data from 2009 to 2010)


select distinct year(dt) from calendar  ;
-- Answer this table has data from 2016-2017

# 3: Find listings that are completely available for the entire year (available for 365 days)
select  listing_id,count(distinct dt) as day
from calendar
where available = 't'
group by 1
having count(distinct dt) = 365;

-- Answer list top5
--  listing_id      day
     10811,         365
     45987,         365
     59776,         365
     182049,        365
     238846,        365



# 4: How many listings have been completely booked for the year (0 days available)?

select count(distinct listing_id) num_unavailable
from (select distinct listing_id, count(distinct dt)
      from calendar
      where available = 'f'
      group by 1
      having count(distinct dt) = 365
)as sub;            -- Answer 679 listings have been completely booked for the year


# 5: Which city has the most listings?


select city,count(*)
from listings
group by 1
order by 2 desc ;  -- Answer Boston has the most listings


# 6: Which street/st/ave has the most number of listings in Boston?
# (Note:  `beacon street` and `beacon st` should be considered the same street)
# (Hint: SUBSTRING_INDEX() function）

-- step1 use SUBSTRING_INDEX() function and upper function to remove duplicate street name
select * from listings;
select upper(substring_index(street,' ',1)) as street_first_name,count(*) number
from listings
group by 1
order by 2 desc;  -- the most listing street name start with commonwealth

-- Find solution ,back to listings table to confirm the full name of commonwealth (to confirm its st or ave or rd)
select street
from listings
where street like '%commonwealth%';

-- Answer the most listings street is Commonwealth Avenue












# 7: In the calendar table, how many listings charge different prices for weekends and weekdays?
# Hint: use average weekend price vs average weekday price

-- step find average weekend price vs average weekday price for each listing_id and select the list has difference
select distinct listing_id,
    avg(case when weekday(dt) in (0,1,2,3,4) then substr(price,2,7) else 0 end) as weekdayprice,
       avg(case when weekday(dt) in(5,6) then substr(price,2,7) else 0 end) as weekendprice

from calendar
where available = 't'
group by 1
having weekdayprice - weekendprice <> 0;


-- Find solution
select count(distinct listing_id)
from (select distinct listing_id,
                      avg(case when weekday(dt) in (0, 1, 2, 3, 4) then substr(price, 2, 7) else 0 end) as weekdayprice,
                      avg(case when weekday(dt) in (5, 6) then substr(price, 2, 7) else 0 end)          as weekendprice

      from calendar
      where available = 't'
      group by 1
      having weekdayprice - weekendprice <> 0)as sub; -- Andwer 2884 listings charge different prices for weekends and weekdays




########################################################################################################################
# Tutorial - Create Tables
# Create and load calendar table
drop table if exists airbnb.calendar;

create table airbnb.calendar (
    listing_id            bigint,
    dt                    char(10),
    available             char(1),
    price                  varchar(20)
);

truncate airbnb.calendar;

-- load data into the calendar table
load data local infile 'C:/Users/User/Desktop/wecloud data/airbnb/calendar.csv'
into table airbnb.calendar
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines;

# test calendar table
select * from airbnb.calendar limit 5;
select * from airbnb.calendar where listing_id=14204600 and dt='2017-08-20';

# Create listings table
drop table if exists airbnb.listings;
create table airbnb.listings (
    id bigint,
    listing_url text,
    scrape_id bigint,
    last_scraped char(10),
    name text,
    summary text,
    space text,
    description text,
    experiences_offered text,
    neighborhood_overview text,
    notes text,
    transit text,
    access text,
    interaction text,
    house_rules text,
    thumbnail_url text,
    medium_url text,
    picture_url text,
    xl_picture_url text,
    host_id bigint,
    host_url text,
    host_name varchar(100),
    host_since char(10),
    host_location text,
    host_about text,
    host_response_time text,
    host_response_rate text,
    host_acceptance_rate text,
    host_is_superhost char(1),
    host_thumbnail_url text,
    host_picture_url text,
    host_neighbourhood text,
    host_listings_count int,
    host_total_listings_count int,
    host_verifications text,
    host_has_profile_pic char(1),
    host_identity_verified char(1),
    street text,
    neighbourhood text,
    neighbourhood_cleansed text,
    neighbourhood_group_cleansed text,
    city text,
    state text,
    zipcode text,
    market text,
    smart_location text,
    country_code text,
    country text,
    latitude text,
    longitude text,
    is_location_exact text,
    property_type text,
    room_type text,
    accommodates int,
    bathrooms text,
    bedrooms text,
    beds text,
    bed_type text,
    amenities text,
    square_feet text,
    price text,
    weekly_price text,
    monthly_price text,
    security_deposit text,
    cleaning_fee text,
    guests_included int,
    extra_people text,
    minimum_nights int,
    maximum_nights int,
    calendar_updated text,
    has_availability varchar(10),
    availability_30 int,
    availability_60 int,
    availability_90 int,
    availability_365 int,
    calendar_last_scraped varchar(10),
    number_of_reviews int,
    first_review varchar(10),
    last_review varchar(10),
    review_scores_rating text,
    review_scores_accuracy text,
    review_scores_cleanliness text,
    review_scores_checkin text,
    review_scores_communication text,
    review_scores_location text,
    review_scores_value text,
    requires_license char(1),
    license text,
    jurisdiction_names text,
    instant_bookable char(1),
    cancellation_policy varchar(20),
    require_guest_profile_picture char(1),
    require_guest_phone_verification char(1),
    calculated_host_listings_count int,
    reviews_per_month text
);


truncate airbnb.listings;


load data local infile 'C:/Users/User/Desktop/wecloud data/airbnb/listings.csv'
into table airbnb.listings
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines;


# Create and load reviews table
drop table if exists airbnb.reviews;
create table airbnb.reviews (
    listing_id bigint,
    id bigint,
    date varchar(10),
    reviewer_id bigint,
    reviewer_name text,
    comments text
);

truncate airbnb.reviews;


load data local infile 'C:/Users/User/Desktop/wecloud data/airbnb/reviews.csv'
into table airbnb.reviews
fields terminated by ',' ENCLOSED BY '"'
lines terminated by '\n'
ignore 1 lines;
