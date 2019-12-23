DROP TABLE IF EXISTS dbn_to_type;
CREATE TABLE dbn_to_type (
    dbn text primary key,
    type text
);

CREATE INDEX ON dbn_to_type (type);
