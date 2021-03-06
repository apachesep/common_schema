
-- 
-- Summary of processlist: number of connected, sleeping, running connections and slow query count
-- 

CREATE OR REPLACE
ALGORITHM = UNDEFINED
SQL SECURITY INVOKER
VIEW processlist_summary AS
  SELECT 
    COUNT(*) AS count_processes,
    SUM(COMMAND != 'Sleep') AS active_processes,
    SUM(COMMAND = 'Sleep') AS sleeping_processes,
    SUM((COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump')) AS active_queries, 
    IFNULL(SUM(IF(
        (COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump'),
        TIME >= 1,
        NULL
      )), 0) AS num_queries_over_1_sec,
    IFNULL(SUM(IF(
        (COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump'),
        TIME >= 10,
        NULL
      )), 0) AS num_queries_over_10_sec,
    IFNULL(SUM(IF(
        (COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump'),
        TIME >= 60,
        NULL
      )), 0) AS num_queries_over_60_sec,
    IFNULL(AVG(IF(
        (COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump'),
        TIME,
        NULL
      )), 0) AS average_active_time,
    IFNULL(CAST(
      split_token(
        GROUP_CONCAT(
          IF(
            (COMMAND != 'Sleep') AND (USER != 'system user') AND (COMMAND != 'Binlog Dump'),
            TIME,
            NULL
          ) ORDER BY TIME
        ), 
        ',', COUNT(*)*95/100
      ) AS DECIMAL(10,2)
    ), 0) AS median_95pct_active_time
  FROM 
    INFORMATION_SCHEMA.PROCESSLIST 
  WHERE 
    id != CONNECTION_ID()
;
