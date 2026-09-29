# Part 2: Incremental Ingestion, AWS Lambda & Amazon Athena

This phase extends the pipeline to support incremental data updates from a live API, bypassing traditional Redshift clusters in favor of a serverless analytics approach.

## Workflow Summary
1.  **Live Ordering API:** A local `FastAPI` server simulates incoming e-commerce orders, exposed to the internet via `ngrok`.
2.  **AWS Lambda Ingestion:** A serverless Lambda function triggers on a schedule to fetch new orders from the API endpoint and stores them as JSON files in the S3 Raw bucket.
3.  **Data Unification:** PySpark notebooks read both the historical Parquet files and the new JSON orders, transforming and merging them into the final curated tables.
4.  **Data Cataloging (AWS Glue):** An AWS Glue Crawler scans the curated S3 bucket to infer schemas and automatically build the AWS Data Catalog.
5.  **Serverless Analytics (Amazon Athena):** Utilizing standard SQL within Amazon Athena to query the S3 Parquet files directly, extracting business insights such as running sales, month-over-month growth, and customer ranking without provisioning database servers.