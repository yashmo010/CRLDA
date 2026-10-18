WITH seg AS (
    SELECT grade,
           CASE WHEN dti < 10 THEN 'under 10'
                WHEN dti < 20 THEN '10 to 20'
                WHEN dti < 30 THEN '20 to 30'
                ELSE '30 plus' END AS dti_group,
           COUNT(*) AS loans,
           SUM(is_default) AS defaults
    FROM loans_matured
    GROUP BY 1, 2
),
ranked AS (
    SELECT *,
           defaults::numeric / loans AS default_rate,
           SUM(loans)    OVER (ORDER BY defaults::numeric / loans DESC) AS cum_loans,
           SUM(defaults) OVER (ORDER BY defaults::numeric / loans DESC) AS cum_defaults
    FROM seg
)
SELECT grade, dti_group, loans,
       ROUND(default_rate, 3) AS default_rate,
       ROUND(100.0 * cum_loans    / (SELECT SUM(loans)    FROM seg), 1) AS pct_loans_rejected,
       ROUND(100.0 * cum_defaults / (SELECT SUM(defaults) FROM seg), 1) AS pct_defaults_avoided
FROM ranked
ORDER BY default_rate DESC;