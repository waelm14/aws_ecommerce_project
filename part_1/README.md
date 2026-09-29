# Part 1: Historical Data & PySpark ETL

This phase focuses on establishing the baseline data warehouse using static historical data.

## Workflow Summary
1.  **Data Generation:** Python scripts generate massive amounts of dummy e-commerce data (Customers, Products, Orders, etc.) in CSV format.
2.  **Cloud Storage:** Uploading the raw CSV files to `s3://.../raw/ecommerce/`.
3.  **Data Transformation (PySpark):** 
    *   Connecting to the S3 bucket using `boto3` and Spark.
    *   Performing data quality checks (handling nulls, duplicates, and invalid records).
    *   Transforming the flat raw data into a structured **Star Schema** (Fact and Dimension tables).
    *   Saving the curated tables back to S3 in optimized `Parquet` format.