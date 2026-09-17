import os
from pathlib import Path

import boto3
from dotenv import load_dotenv


# =========================
# Load environment variables
# =========================

ENV_PATH = ".env"

load_dotenv(ENV_PATH, override=True)


# =========================
# Configuration
# =========================

OUTPUT_DIR = os.getenv("OUTPUT_DIR", "ecommerce_data")

BUCKET_NAME = os.getenv(
    "AWS_BUCKET_NAME",
    "aws-ecommerce-data-omar-2026"
)

AWS_REGION = os.getenv(
    "AWS_REGION",
    "eu-north-1"
)

S3_PREFIX = os.getenv(
    "S3_PREFIX",
    "raw/ecommerce"
)


# =========================
# Create S3 client
# =========================

s3 = boto3.client(
    "s3",
    region_name=AWS_REGION
)


# =========================
# Upload files
# =========================

def upload_directory_to_s3(local_directory, bucket_name, s3_prefix):

    local_directory = Path(local_directory)

    if not local_directory.exists():
        raise FileNotFoundError(
            f"Directory not found: {local_directory}"
        )

    files = [
        file
        for file in local_directory.rglob("*")
        if file.is_file()
    ]

    if not files:
        print("No files found.")
        return

    print(f"Found {len(files)} files.")
    print()

    for file_path in files:

        # Example:
        # ecommerce_data/customers.csv
        #
        # becomes:
        # raw/ecommerce/customers.csv

        relative_path = file_path.relative_to(local_directory)

        s3_key = f"{s3_prefix}/{relative_path.as_posix()}"

        print(
            f"Uploading: {file_path} "
            f"-> s3://{bucket_name}/{s3_key}"
        )

        s3.upload_file(
            str(file_path),
            bucket_name,
            s3_key
        )

        print("Uploaded successfully.")
        print()


# =========================
# Main
# =========================

if __name__ == "__main__":

    upload_directory_to_s3(
        OUTPUT_DIR,
        BUCKET_NAME,
        S3_PREFIX
    )

    print("================================")
    print("All files uploaded successfully")
    print("================================")