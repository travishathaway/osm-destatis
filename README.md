# OSM and Destatis

This is a place for me to brainstorm new projects for working with
[OpenStreetMap](https://openstreetmap.org) and [DEStatis](https://www.destatis.de/).


## PgOSM Flex

Notes on using PgOSM Flex for the project.

Here's the command I used to import the data:

```bash

docker exec -it \
    pgosm python3 docker/pgosm_flex.py \
    --region=europe \
    --subregion=germany
```

The above command failed miserably. It would either fail because of a 
md5sum mismatch or the process would run for a while and then crash the
docker host! (never seen that before)

It works when you use a smaller data file though, so for now I'm going 
to stick with that.