----------------------
--- TABLE CREATION ---
----------------------

CREATE TABLE observability ( -- Table for tess-point output
    ID BIGINT,
    ra DOUBLE,
    dec DOUBLE,
    sector BIGINT,
    camera BIGINT,
    ccd BIGINT,
    col_pix DOUBLE,
    row_pix DOUBLE
);

INSERT INTO observability 
    SELECT * FROM read_csv("./tmp/pointings/*"); -- Collect tess-point output

-- Collect downloaded target lists from various pipelines
CREATE TABLE qlp_targets (
    ID BIGINT,
    ra DOUBLE,
    dec DOUBLE,
    sector BIGINT
);

INSERT INTO qlp_targets 
    SELECT * FROM read_csv("./hlsp_lists/qlp/*/*.csv", hive_partitioning = TRUE);

CREATE TABLE tglc_targets (
    DR3 BIGINT,
    ID BIGINT,
    ra DOUBLE,
    dec DOUBLE,
    sector BIGINT
);

INSERT INTO tglc_targets 
    SELECT * FROM read_csv("./hlsp_lists/tglc/*/*.csv", hive_partitioning = TRUE);


CREATE TABLE spoc2m_targets (
    ID BIGINT,
    camera BIGINT,
    ccd BIGINT,
    Tmag DOUBLE,
    ra DOUBLE,
    dec DOUBLE,
    sector BIGINT
);

INSERT INTO spoc2m_targets 
    SELECT * FROM read_csv("./hlsp_lists/spoc/*/*.csv", hive_partitioning = TRUE);


CREATE TABLE spoc20s_targets (
    ID BIGINT,
    camera BIGINT,
    ccd BIGINT,
    Tmag DOUBLE,
    ra DOUBLE,
    dec DOUBLE,
    sector BIGINT
);

INSERT INTO spoc20s_targets
    SELECT * FROM read_csv("./hlsp_lists/spoc20s/*/*.csv", hive_partitioning = TRUE);

------------------------------------------------------
--- Join product target lists with our target list ---
------------------------------------------------------

CREATE TABLE results AS
SELECT
    o.*,
    tglc.DR3,
    CASE WHEN tglc.id IS NOT NULL THEN 1 ELSE 0 END AS has_tglc,
    CASE WHEN qlp.id IS NOT NULL THEN 1 ELSE 0 END AS has_qlp,
    CASE WHEN spoc2m.id IS NOT NULL THEN 1 ELSE 0 END AS has_spoc2m,
    CASE WHEN spoc20s.id IS NOT NULL THEN 1 ELSE 0 END AS has_spoc20s
FROM observability o
LEFT JOIN tglc_targets tglc 
       ON o.id = tglc.id AND o.sector = tglc.sector
LEFT JOIN qlp_targets qlp 
       ON o.id = qlp.id AND o.sector = qlp.sector
LEFT JOIN spoc2m_targets spoc2m 
       ON o.id = spoc2m.id AND o.sector = spoc2m.sector
LEFT JOIN spoc20s_targets spoc20s 
       ON o.id = spoc20s.id AND o.sector = spoc20s.sector;

CREATE TYPE product_enum AS ENUM ('SPOC 20s', 'SPOC 2m', 'QLP', 'TGLC', 'FFI');
ALTER TABLE results ADD COLUMN product product_enum;
UPDATE results
SET product = CASE 
    WHEN has_spoc20s THEN 'SPOC 20s'
    WHEN has_spoc2m THEN 'SPOC 2m'
    WHEN has_qlp     THEN 'QLP'
    WHEN has_tglc    THEN 'TGLC'
    ELSE 'FFI'
END;

COPY results TO "./data/output.parquet"