# AWS E-Commerce Data Engineering Pipeline

An end-to-end Data Engineering pipeline building a scalable data warehouse for an e-commerce platform. This project processes historical data and integrates real-time incremental data streams using AWS cloud services.

## Project Architecture Overview

The pipeline is divided into two main phases to handle different data ingestion and processing requirements:

*   **Part 1: Historical Data Processing (Batch ETL):** Generating dummy e-commerce CSV datasets, uploading them to an S3 Raw bucket, and performing data quality checks, cleaning, and dimensional modeling (Star Schema) using PySpark.
*   **Part 2: Incremental API Ingestion & Analytics:** Simulating a live ordering system using FastAPI and ngrok. AWS Lambda ingests the new JSON orders into S3. The data is processed, cataloged via AWS Glue Crawler, and queried using Amazon Athena.

## Architecture Diagram

```mermaid
graph TD
    subgraph Data Sources
        A[Historical Data CSV]
        B[Live API - FastAPI/ngrok]
    end

    subgraph AWS Cloud
        C[Amazon S3 - raw/]
        D[AWS Lambda]
        E[Amazon S3 - api_raw/]
        
        A -->|Upload| C
        B -->|Fetch JSON| D
        D -->|Ingest| E
        
        C --> F[PySpark / ETL Processing]
        E --> F
        
        F -->|Star Schema| G[Amazon S3 - curated/ Parquet]
        
        G --> H[AWS Glue Crawler]
        H --> I[AWS Data Catalog]
        
        I --> J[Amazon Athena]
        G -.->|Query Execution| J
    end
    
    J --> K[SQL Analytics & Reporting]