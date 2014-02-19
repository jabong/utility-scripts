-- Creating generic stored procedure for creating an index over particular column
-- DELIMITER $$

DROP PROCEDURE IF EXISTS create_index_if_not_exists;

CREATE PROCEDURE create_index_if_not_exists (IN p_tableName VARCHAR(128), IN p_indexName VARCHAR(128), IN p_columnName VARCHAR(128), IN p_indextype enum ('UNIQUE', 'INDEX', 'PRIMARY'))
BEGIN

DECLARE indexCount INT (2);
SELECT COUNT(1) INTO indexCount FROM information_schema.statistics WHERE `table_name` = p_tableName AND `index_name` = p_indexName;

IF(indexCount = 0) THEN
    IF p_indextype = 'UNIQUE' THEN
        SET @createIndexStmt = CONCAT('CREATE UNIQUE INDEX ', p_indexName, ' ON ', p_tableName, ' ( ', p_columnName , ')');
    ELSEIF p_indextype = 'PRIMARY' THEN
        SET @createIndexStmt = CONCAT('ALTER TABLE ', p_tableName,' ADD PRIMARY KEY (', p_columnName , ')');
    ELSE
        SET @createIndexStmt = CONCAT('CREATE INDEX ', p_indexName, ' ON ', p_tableName, ' ( ', p_columnName , ')');
    END IF;

    PREPARE stmt FROM @createIndexStmt; EXECUTE stmt; DEALLOCATE PREPARE stmt;
END IF;

END;
-- DELIMITER ;

-- Example Procedure CALL --
CALL create_index_if_not_exists('table_name', 'field_name' , 'field_name', 'UNIQUE');
