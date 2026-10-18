SELECT purpose,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS actual_rate,
       ROUND(AVG(grade_rate)::numeric, 3) AS expected_rate,
       ROUND((AVG(is_default) - AVG(grade_rate))::numeric, 3) AS gap
FROM (
    SELECT purpose, is_default,
           AVG(is_default) OVER (PARTITION BY grade) AS grade_rate
    FROM loans
) t
GROUP BY purpose
ORDER BY gap DESC;