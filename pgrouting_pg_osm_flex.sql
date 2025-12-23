-- ============================================================================
-- Migration Script: Replace pgr_nodeNetwork with pgr_separateCrossing/Touching
-- Table: routing.road_line
-- pgRouting Version: 4.x
-- ============================================================================

CREATE OR REPLACE FUNCTION routing.migrate_node_network(
    p_tolerance DOUBLE PRECISION DEFAULT 0.001,
    p_geom_column TEXT DEFAULT 'geom',
    p_id_column TEXT DEFAULT 'id',
    p_cost_column TEXT DEFAULT 'cost',
    p_reverse_cost_column TEXT DEFAULT 'reverse_cost'
)
RETURNS TABLE(
    step TEXT,
    status TEXT,
    rows_affected BIGINT,
    message TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_edges_separated BIGINT := 0;
    v_crossing_count BIGINT := 0;
    v_touching_count BIGINT := 0;
    v_vertices_created BIGINT := 0;
    v_edges_updated BIGINT := 0;
    v_old_edges_deleted BIGINT := 0;
    v_sql TEXT;
BEGIN
    -- ========================================================================
    -- STEP 1: Validate prerequisites
    -- ========================================================================
    step := 'Validation';
    
    -- Check if table exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'routing' AND table_name = 'road_line'
    ) THEN
        status := 'ERROR';
        rows_affected := 0;
        message := 'Table routing.road_line does not exist';
        RETURN NEXT;
        RETURN;
    END IF;
    
    -- Check if geometry column exists
    EXECUTE format('SELECT COUNT(*) FROM routing.road_line WHERE %I IS NOT NULL LIMIT 1', p_geom_column);
    
    status := 'SUCCESS';
    rows_affected := 0;
    message := 'Prerequisites validated';
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 2: Backup original table (optional but recommended)
    -- ========================================================================
    step := 'Backup';
    
    EXECUTE 'DROP TABLE IF EXISTS routing.road_line_backup CASCADE';
    EXECUTE 'CREATE TABLE routing.road_line_backup AS SELECT * FROM routing.road_line';
    
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    status := 'SUCCESS';
    message := 'Backup table created: routing.road_line_backup';
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 3: Add old_id column if it doesn't exist
    -- ========================================================================
    step := 'Add old_id column';
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'routing' 
        AND table_name = 'road_line' 
        AND column_name = 'old_id'
    ) THEN
        EXECUTE 'ALTER TABLE routing.road_line ADD COLUMN old_id BIGINT';
        status := 'SUCCESS';
        rows_affected := 0;
        message := 'Column old_id added to routing.road_line';
    ELSE
        status := 'SKIPPED';
        rows_affected := 0;
        message := 'Column old_id already exists';
    END IF;
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 4: Separate crossing edges
    -- ========================================================================
    step := 'Separate crossing edges';
    
    v_sql := format(
        'INSERT INTO routing.road_line (old_id, %I) 
         SELECT id, geom 
         FROM pgr_separateCrossing(
             ''SELECT %I as id, %I as geom FROM routing.road_line'', 
             %L
         )',
        p_geom_column,
        p_id_column,
        p_geom_column,
        p_tolerance
    );
    
    EXECUTE v_sql;
    GET DIAGNOSTICS v_crossing_count = ROW_COUNT;
    
    status := 'SUCCESS';
    rows_affected := v_crossing_count;
    message := format('Inserted %s new edge segments from crossing edges', v_crossing_count);
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 5: Separate touching edges
    -- ========================================================================
    step := 'Separate touching edges';
    
    v_sql := format(
        'INSERT INTO routing.road_line (old_id, %I) 
         SELECT id, geom 
         FROM pgr_separateTouching(
             ''SELECT %I as id, %I as geom FROM routing.road_line'', 
             %L
         )',
        p_geom_column,
        p_id_column,
        p_geom_column,
        p_tolerance
    );
    
    EXECUTE v_sql;
    GET DIAGNOSTICS v_touching_count = ROW_COUNT;
    
    status := 'SUCCESS';
    rows_affected := v_touching_count;
    message := format('Inserted %s new edge segments from touching edges', v_touching_count);
    RETURN NEXT;
    
    v_edges_separated := v_crossing_count + v_touching_count;
    
    -- ========================================================================
    -- STEP 6: Update cost and reverse_cost for new segments
    -- ========================================================================
    step := 'Update costs';
    
    IF v_edges_separated > 0 THEN
        v_sql := format(
            'WITH costs AS (
                SELECT e2.%I as id,
                    sign(e1.%I) * ST_Length(e2.%I) AS cost,
                    sign(e1.%I) * ST_Length(e2.%I) AS reverse_cost
                FROM routing.road_line e1 
                JOIN routing.road_line e2 ON (e1.%I = e2.old_id)
                WHERE e2.old_id IS NOT NULL
            )
            UPDATE routing.road_line e 
            SET %I = c.cost,
                %I = c.reverse_cost
            FROM costs AS c 
            WHERE e.%I = c.id',
            p_id_column,
            p_cost_column,
            p_geom_column,
            p_reverse_cost_column,
            p_geom_column,
            p_id_column,
            p_cost_column,
            p_reverse_cost_column,
            p_id_column
        );
        
        EXECUTE v_sql;
        GET DIAGNOSTICS v_edges_updated = ROW_COUNT;
        
        status := 'SUCCESS';
        rows_affected := v_edges_updated;
        message := format('Updated costs for %s new segments', v_edges_updated);
    ELSE
        status := 'SKIPPED';
        rows_affected := 0;
        message := 'No new segments to update';
    END IF;
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 7: Rebuild vertices table
    -- ========================================================================
    step := 'Rebuild vertices';
    
    EXECUTE 'DROP TABLE IF EXISTS routing.road_line_vertices_pgr CASCADE';
    
    v_sql := format(
        'CREATE TABLE routing.road_line_vertices_pgr AS 
         SELECT * FROM pgr_extractVertices(
             ''SELECT %I as id, %I as geom FROM routing.road_line ORDER BY %I''
         )',
        p_id_column,
        p_geom_column,
        p_id_column
    );
    
    EXECUTE v_sql;
    GET DIAGNOSTICS v_vertices_created = ROW_COUNT;
    
    -- Create indexes on vertices table
    EXECUTE 'CREATE INDEX IF NOT EXISTS road_line_vertices_pgr_id_idx 
             ON routing.road_line_vertices_pgr(id)';
    EXECUTE 'CREATE INDEX IF NOT EXISTS road_line_vertices_pgr_geom_idx 
             ON routing.road_line_vertices_pgr USING GIST(geom)';
    
    status := 'SUCCESS';
    rows_affected := v_vertices_created;
    message := format('Created vertices table with %s vertices', v_vertices_created);
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 8: Update source column
    -- ========================================================================
    step := 'Update source';
    
    -- First, add source column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'routing' 
        AND table_name = 'road_line' 
        AND column_name = 'source'
    ) THEN
        EXECUTE 'ALTER TABLE routing.road_line ADD COLUMN source BIGINT';
    END IF;
    
    v_sql := format(
        'UPDATE routing.road_line AS e 
         SET source = v.id 
         FROM routing.road_line_vertices_pgr AS v 
         WHERE ST_StartPoint(e.%I) = v.geom',
        p_geom_column
    );
    
    EXECUTE v_sql;
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    
    status := 'SUCCESS';
    message := format('Updated source for %s edges', rows_affected);
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 9: Update target column
    -- ========================================================================
    step := 'Update target';
    
    -- First, add target column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'routing' 
        AND table_name = 'road_line' 
        AND column_name = 'target'
    ) THEN
        EXECUTE 'ALTER TABLE routing.road_line ADD COLUMN target BIGINT';
    END IF;
    
    v_sql := format(
        'UPDATE routing.road_line AS e 
         SET target = v.id 
         FROM routing.road_line_vertices_pgr AS v 
         WHERE ST_EndPoint(e.%I) = v.geom',
        p_geom_column
    );
    
    EXECUTE v_sql;
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    
    status := 'SUCCESS';
    message := format('Updated target for %s edges', rows_affected);
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 10: Delete original edges that were split
    -- ========================================================================
    step := 'Delete original edges';
    
    IF v_edges_separated > 0 THEN
        EXECUTE format(
            'DELETE FROM routing.road_line 
             WHERE old_id IS NULL 
             AND %I IN (
                 SELECT DISTINCT old_id 
                 FROM routing.road_line 
                 WHERE old_id IS NOT NULL
             )',
            p_id_column
        );
        
        GET DIAGNOSTICS v_old_edges_deleted = ROW_COUNT;
        
        status := 'SUCCESS';
        rows_affected := v_old_edges_deleted;
        message := format('Deleted %s original edges that were split', v_old_edges_deleted);
    ELSE
        status := 'SKIPPED';
        rows_affected := 0;
        message := 'No original edges to delete';
    END IF;
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 11: Create indexes for performance
    -- ========================================================================
    step := 'Create indexes';
    
    EXECUTE format('CREATE INDEX IF NOT EXISTS road_line_source_idx 
                    ON routing.road_line(source)');
    EXECUTE format('CREATE INDEX IF NOT EXISTS road_line_target_idx 
                    ON routing.road_line(target)');
    EXECUTE format('CREATE INDEX IF NOT EXISTS road_line_geom_idx 
                    ON routing.road_line USING GIST(%I)', p_geom_column);
    
    status := 'SUCCESS';
    rows_affected := 3;
    message := 'Created indexes on source, target, and geometry';
    RETURN NEXT;
    
    -- ========================================================================
    -- STEP 12: Summary
    -- ========================================================================
    step := 'Summary';
    status := 'COMPLETE';
    rows_affected := v_edges_separated;
    message := format(
        'Migration complete: %s crossing + %s touching = %s total new segments created, %s original edges removed',
        v_crossing_count,
        v_touching_count,
        v_edges_separated,
        v_old_edges_deleted
    );
    RETURN NEXT;
    
EXCEPTION
    WHEN OTHERS THEN
        step := 'ERROR';
        status := 'FAILED';
        rows_affected := 0;
        message := format('Error: %s - %s', SQLERRM, SQLSTATE);
        RETURN NEXT;
        RAISE;
END;
$$;

-- ============================================================================
-- USAGE INSTRUCTIONS
-- ============================================================================
-- 
-- Basic usage with default parameters:
-- SELECT * FROM routing.migrate_node_network();
--
-- Custom parameters:
-- SELECT * FROM routing.migrate_node_network(
--     p_tolerance := 0.001,
--     p_geom_column := 'geom',
--     p_id_column := 'id',
--     p_cost_column := 'cost',
--     p_reverse_cost_column := 'reverse_cost'
-- );
--
-- To restore from backup if needed:
-- DROP TABLE routing.road_line;
-- ALTER TABLE routing.road_line_backup RENAME TO road_line;
-- ============================================================================

COMMENT ON FUNCTION routing.migrate_node_network IS 
'Migrates routing.road_line table from pgr_nodeNetwork approach to pgr_separateCrossing/pgr_separateTouching. 
Creates a backup table, separates crossing and touching edges, updates topology, and rebuilds vertices table.
Compatible with pgRouting 4.x';
