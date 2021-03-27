#!/bin/bash

set -e

[[ -z "${PROJECT}" ]] && die "You must pass a project name in parameter. For example: $0 geocoder"

docker-compose -p ${PROJECT} rm -sf redis-server-lu
docker-compose -p ${PROJECT} run --rm --entrypoint sh redis-server-lu -c "rm -f /data/*"
docker-compose -p ${PROJECT} up -d redis-server-lu

wget https://download.data.public.lu/resources/adresses-georeferencees-bd-adresses/20170918-053115/addresses.geojson -O addresses-lu/addresses.geojson

jq -c '.features |
map(.properties + {lon: .geometry.coordinates[0][0], lat: .geometry.coordinates[0][1]}) |
group_by(.code_postal, .localite, .id_caclr_rue, .rue) |
map({name: .[0].rue, city: .[0].localite, postcode: .[0].code_postal, housenumbers: map({(.numero): {lat: .lat, lon: .lon}}) | add }) |
.[] |
{type: "street", city: .city, name: .name, postcode: .postcode, lat: ((.housenumbers | map(.lat) | add) / (.housenumbers | length)), lon: ((.housenumbers | map(.lon) | add) / (.housenumbers | length)), importance: 0.2, housenumbers: .housenumbers} |
del(.housenumbers."")' addresses-lu/addresses.geojson > addresses-lu/streets.json

jq -s -c 'group_by(.city) |
map({name: .[0].city, postcode: map(.postcode) |
unique, lat: map(.lat) |
add, lon: map(.lon) |
add, size: length}) |
map({type: "municipality", name: .name, city: .name, postcode: .postcode, lat: (.lat / .size), lon: (.lon / .size), importance: [1, .size / 20 + 0.2] | min}) |
.[]' addresses-lu/streets.json > addresses-lu/cities.json

cat addresses-lu/cities.json addresses-lu/streets.json > addresses-lu/addresses.json

docker-compose run --rm --entrypoint /bin/bash addok-lu -c "cat addresses/addresses.json | addok batch"

docker-compose exec addok-lu addok ngrams

docker-compose exec redis-server-lu redis-cli BGSAVE
