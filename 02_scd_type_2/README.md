# Day 02 Dimensional Data Modeling - Slowly Changing Dimensions

## Official Links

- [YouTube lecture discussion](https://youtu.be/emQM9gYh0Io?si=sCHLIaLsDMZDGjsU)
- [YouTube lab discussion]()
- [GitHub](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials/1-dimensional-data-modeling)

## Personal Key Takeaways

- On SCD Type 2
    - can be built in two ways
        1. using a query to do the full historical SCD; uses `LAG()`
            to compare values from the previous *state* and check if
            there's a change
        1. using an incremental query, which does the following:
            1. get the latest dimension values for each entity (i.e., 
                find the latest state)
            1. get the historical dimension values for each entity (i.e.,
                find all states before the latest state)
            1. `INNER JOIN` the incoming data to the latest dimension values
                to get the portion of the incoming data that did not change
                any dimension value (i.e., find unchanged from incoming)
            1. `LEFT JOIN` the incoming data to the latest dimension values
                to get the portion of the incoming data that did change one
                or more dimension values (i.e., find changed from incoming)
            1. `LEFT JOIN` the incoming data to the latest dimension values
                to get the portion of the incoming data that are not in
                the latest dimension values (i.e., find new from incoming)
            1. finally, `UNION ALL` the *historical*, *unchanged*, *changed*,
                and the *new* records to build the latest SCD model.
    - what blew my mind is the use of a special marker for when the data was
        loaded into the SCD model. in the lab examples, this is the
        `current_season` from the `players_scd` table.
            - I would like to call it `load_date`
            - if you check back from the incremental build, *historical* is
                always included in the latest SCD build. this means that
                whenever you try to build or refresh the SCD model, you will
                always compute for the *full* history of changes.
            - does this mean that we are duplicating a lot?
                - yes, but storage is cheap
                - if partitions are correctly setup (partition by `load_date`),
                    then you can reduce storage use by deleting old partitions
                - moreover, this marker is what helps the SCD model to become
                    **idempotent**
                - moreover, this what helps you to show *"what are the historical
                    as of `load_date`"*
            - I previously thought that `start_date` and `end_date` are the only
                important fields on an SCD Type 2 model and there's no concept of
                `load_date` (i.e., just the latest history is enough; while it
                should have contained the history of histories. Thus, this is truly
                an eye-opener for me.