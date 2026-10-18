SELECT grade, term,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS default_rate
FROM loans_matured
GROUP BY grade, term
ORDER BY grade, term;