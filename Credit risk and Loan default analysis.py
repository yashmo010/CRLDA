# %%
import pandas as pd

# Download "Lending Club" from Kaggle (accepted_2007_to_2018Q4.csv)
df = pd.read_csv("accepted_2007_to_2018Q4.csv.gz", low_memory=False)

# Random 200k sample for faster work
df = df.sample(200_000, random_state=42).reset_index(drop=True)

print(df.shape)
df.info()
print(df["loan_status"].value_counts())

# %%

import pandas as pd

cols = ["id", "loan_status", "loan_amnt", "term", "int_rate", "installment", "grade",
        "sub_grade", "emp_length", "home_ownership", "annual_inc", "verification_status",
        "issue_d", "purpose", "addr_state", "dti", "delinq_2yrs", "fico_range_low",
        "fico_range_high", "open_acc", "revol_util", "total_acc", "earliest_cr_line"]

closed = {
    "Fully Paid": 0,
    "Does not meet the credit policy. Status:Fully Paid": 0,
    "Charged Off": 1,
    "Does not meet the credit policy. Status:Charged Off": 1,
    "Default": 1,
}

parts = []
for chunk in pd.read_csv("accepted_2007_to_2018Q4.csv.gz", usecols=cols,
                         chunksize=200_000, low_memory=False):
    chunk = chunk[chunk["loan_status"].isin(closed)].copy()
    chunk["default"] = chunk["loan_status"].map(closed)
    parts.append(chunk)

df = pd.concat(parts, ignore_index=True)
df["issue_d"] = pd.to_datetime(df["issue_d"], format="%b-%Y")
df["issue_year"] = df["issue_d"].dt.year

df.to_csv("loans_clean_raw.csv", index=False)

print(df.shape)
print(df["default"].mean())
print(df.isnull().mean().sort_values(ascending=False).head(10))
# %%

import pandas as pd

df = pd.read_csv("loans_clean_raw.csv", parse_dates=["issue_d"])

# Clean text fields
df["term"] = df["term"].str.strip().str.extract(r"(\d+)").astype(int)
df["emp_length"] = df["emp_length"].fillna("Unknown")
df["int_rate"] = df["int_rate"].astype(float)

# Handle small numeric gaps: fill with the median
for c in ["revol_util", "dti", "delinq_2yrs", "open_acc", "total_acc", "annual_inc"]:
    df[c] = df[c].fillna(df[c].median())

# Remove impossible or extreme values
df = df[(df["annual_inc"] > 0) & (df["dti"] >= 0) & (df["dti"] < 100)]

# Average FICO score and income bands for later segmentation
df["fico"] = (df["fico_range_low"] + df["fico_range_high"]) / 2
df["income_band"] = pd.cut(df["annual_inc"], [0, 30000, 60000, 100000, 150000, float("inf")],
                           labels=["<30K", "30-60K", "60-100K", "100-150K", "150K+"])
df["dti_band"] = pd.cut(df["dti"], [-1, 10, 20, 30, 40, 100],
                        labels=["0-10", "10-20", "20-30", "30-40", "40+"])

df = df.drop(columns=["fico_range_low", "fico_range_high"])
df.to_csv("loans_clean.csv", index=False)

print(df.shape)
print(df.isnull().sum().sum())
print(df.groupby("grade")["default"].mean().round(3))
# %%
