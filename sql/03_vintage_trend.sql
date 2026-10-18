SELECT issue_year,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS default_rate
FROM loans
GROUP BY issue_year
ORDER BY issue_year;