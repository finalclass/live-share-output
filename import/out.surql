-- ------------------------------
-- OPTION
-- ------------------------------

OPTION IMPORT;

-- ------------------------------
-- TABLE: bbb
-- ------------------------------

DEFINE TABLE bbb SCHEMALESS PERMISSIONS NONE;

-- ------------------------------
-- TABLE: test
-- ------------------------------

DEFINE TABLE test SCHEMALESS PERMISSIONS NONE;

-- ------------------------------
-- TRANSACTION
-- ------------------------------

BEGIN TRANSACTION;

-- ------------------------------
-- TABLE DATA: bbb
-- ------------------------------

UPDATE bbb:www CONTENT { id: bbb:www };

-- ------------------------------
-- TABLE DATA: test
-- ------------------------------

UPDATE test:abc CONTENT { id: test:abc };

-- ------------------------------
-- TRANSACTION
-- ------------------------------

COMMIT TRANSACTION;

