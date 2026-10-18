WITH seg AS (
    SELECT grade, dti_band,
           COUNT(*) AS loans,
           SUM(is_default) AS defaults
    FROM loans_matured
    GROUP BY grade, dti_band
),
ranked AS (
    SELECT *,
           defaults::numeric / loans AS default_rate,
           SUM(loans)    OVER (ORDER BY defaults::numeric / loans DESC) AS cum_loans,
           SUM(defaults) OVER (ORDER BY defaults::numeric / loans DESC) AS cum_defaults
    FROM seg
    WHERE loans >= 1000
)
SELECT grade, dti_band, loans,
       ROUND(default_rate, 3) AS default_rate,
       ROUND(100.0 * cum_loans    / (SELECT SUM(loans)    FROM seg), 1) AS pct_loans_rejected,
       ROUND(100.0 * cum_defaults / (SELECT SUM(defaults) FROM seg), 1) AS pct_defaults_avoided
FROM ranked
ORDER BY default_rate DESC;