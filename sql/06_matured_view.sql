CREATE VIEW loans_matured AS
SELECT * FROM loans
WHERE (term = 36 AND issue_year <= 2015)
   OR (term = 60 AND issue_year <= 2013);