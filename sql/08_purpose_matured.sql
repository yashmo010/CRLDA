SELECT purpose,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS default_rate,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_loans
FROM loans_matured
GROUP BY purpose
ORDER BY default_rate DESC;
