Mycelium
========

Mycelium is a small ruby rake task with docker files set up to run a feasibility study on storing all of our engagement data in neo4j.

Mycelium runs its own neo4j docker service with docker-compose, and connects to the fern postgres docker service through the docker-compose networks.

Starting the import
----

First, make sure the neo4j service is running:

```shell
docker-compose up -d neo4j
```

Then, run the importer

```shell
docker-compose run --rm importer
```

Sometimes, if the importer is already built, and the neo4j instance was _just_ started, it will fail to connect. Running the importer a second time usually works.

neo4j-engagement-feasibility server
---

There is a digitalocean server running to run this study. Talk to @amiel if you want access.

To use the neo4j browser with that data, use the following ssh command (assuming you have neo4j-engagement-feasibility set up as an ssh host).

```
ssh neo4j-engagement-feasibility -L 7688:localhost:7687 -L 7475:localhost:7474
```

Then point your browser at http://localhost:7475 and configure it to use bolt://localhost:7688
