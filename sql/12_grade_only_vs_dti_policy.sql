WITH g AS (
    SELECT grade, COUNT(*) AS loans, SUM(is_default) AS defaults
    FROM loans_matured
    GROUP BY grade
),
ranked AS (
    SELECT grade, loans, defaults,
           SUM(loans)    OVER (ORDER BY defaults::numeric / loans DESC) AS cum_loans,
           SUM(defaults) OVER (ORDER BY defaults::numeric / loans DESC) AS cum_defaults
    FROM g
)
SELECT grade,
       ROUND(100.0 * cum_loans    / (SELECT SUM(loans)    FROM g), 1) AS pct_loans_rejected,
       ROUND(100.0 * cum_defaults / (SELECT SUM(defaults) FROM g), 1) AS pct_defaults_avoided
FROM ranked
ORDER BY pct_loans_rejected;