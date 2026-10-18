SELECT grade, dti_band,
       COUNT(*) AS loans,
       ROUND(AVG(is_default)::numeric, 3) AS default_rate
FROM loans_matured
GROUP BY grade, dti_band
ORDER BY grade, dti_band;