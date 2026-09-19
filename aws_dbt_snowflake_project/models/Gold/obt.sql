{{ config(
    materialized='table',
    schema='gold'
) }}


{% set bookings = ref('silver_bookings') %}
{% set listing = ref('silver_listing') %}
{% set hosts = ref('silver_hosts') %}




{% set configs = [
    {
        "table": bookings,
        "columns": "SILVER_bookings.BOOKING_ID, SILVER_bookings.LISTING_ID, SILVER_bookings.BOOKING_DATE, SILVER_bookings.TOTAL_BOOKING_AMOUNT,BOOKING_STATUS",
        "alias": "SILVER_BOOKINGS"
    },
    {
        "table": listing,
        "columns": "SILVER_listing.PROPERTY_TYPE, SILVER_listing.ROOM_TYPE, SILVER_listing.CITY, SILVER_listing.COUNTRY, SILVER_listing.ACCOMMODATES, SILVER_listing.BEDROOMS, SILVER_listing.BATHROOMS, SILVER_listing.PRICE_PER_NIGHT, SILVER_listing.PRICE_PER_NIGHT_TAG, SILVER_listing.CREATED_AT",
        "alias": "SILVER_LISTING",
        "join_condition": "SILVER_bookings.listing_id = SILVER_listing.LISTING_ID"
    },
    {
        "table": hosts,
        "columns": "SILVER_hosts.HOST_ID,SILVER_hosts.HOST_NAME, SILVER_hosts.HOST_SINCE, SILVER_hosts.IS_SUPERHOST, SILVER_hosts.RESPONSE_RATE, SILVER_hosts.RESPONSE_RATE_QUALITY",
        "alias": "SILVER_HOSTS",
        "join_condition": "SILVER_listing.HOST_ID = SILVER_hosts.HOST_ID"
    }
] %}


SELECT

    {% for config in configs %}
        {{ config['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}

FROM

    {% for config in configs %}

        {% if loop.first %}

            {{ config['table'] }} AS {{ config['alias'] }}

        {% else %}

            LEFT JOIN {{ config['table'] }} AS {{ config['alias'] }}
            ON {{ config['join_condition'] }}

        {% endif %}

    {% endfor %}