CREATE VIEW policy_by_grade AS
WITH g AS (
    SELECT grade, COUNT(*) AS loans, SUM(is_default) AS defaults
    FROM loans_matured
    GROUP BY grade
)
SELECT grade, loans, defaults,
       ROUND(defaults::numeric / loans, 3) AS default_rate,
       ROUND(100.0 * SUM(loans)    OVER (ORDER BY defaults::numeric / loans DESC) / SUM(loans)    OVER (), 1) AS pct_loans_rejected,
       ROUND(100.0 * SUM(defaults) OVER (ORDER BY defaults::numeric / loans DESC) / SUM(defaults) OVER (), 1) AS pct_defaults_avoided
FROM g;