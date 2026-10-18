SELECT issue_year, term,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS default_rate
FROM loans
GROUP BY issue_year, term
ORDER BY term, issue_year;