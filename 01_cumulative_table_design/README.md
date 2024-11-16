# Day 01 Dimensional Data Modeling

## Official Links

- [YouTube lecture discussion](https://youtu.be/5U-BbZ9G_xU?si=SLM9Z5p99RoDR6vJ)
- [YouTube lab discussion](https://youtu.be/dWj8VeBEQCc?si=K59v2KuxkqPZtYcM)
- [GitHub](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials/1-dimensional-data-modeling)
    NOTE: the folder also contains files that are not yet used for this "episode"

## Personal Key Takeaways

- OLTP and OLAP is a continuum
    - we get data from application OLTP databases (usually snapshots)
    - from the snapshots, we build the *master data* (the source of truth)
    - from the master data, we build OLAP cubes
    - from OLAP cubes, we build metrics (e.g., aggregations from OLAP cubes)
- Cumulative Table Design
    - has two core components: yesterday's data (the cumulation) and today's data
    - step 1: `FULL OUTER JOIN` yesterday and today data
    - step 2: `COALESCE` non-cumulated fields
    - step 3: hold onto historical values
        - use `COMPLEX` types like `ARRAY`s and `STRUCT`s to cumulate values
        - compute metrics over the period of time 
    - good for historical analysis without *data shuffling*
    - can be used for *state transition analysis*
    - requires sequential processing when backfilling
    - difficulties when handling PII data

