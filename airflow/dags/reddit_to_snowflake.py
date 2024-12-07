import sys, os
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from pipelines.reddit import (
    RedditAPISensor,
    fetch_latest_posts,
    upload_to_s3,
    transform_reddit_data,
)
from pipelines.snowflake import load_snowflake

# aiflow defaut args
default_args = {
    "owner": "dataops",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 3,
    "retry_delay": timedelta(minutes=3),
}


with DAG(
    "reddit_worldnews_pipeline",
    default_args=default_args,
    description="Pipeline to fetch latest posts from Reddit worldnews",
    schedule_interval="0 */3 * * *",
    start_date=datetime(2024, 12, 1),
    catchup=False,
    tags=['reddit']
) as dag:

    # Task 1: Sensor to check Reddit API availability
    wait_for_reddit_api = RedditAPISensor(
        task_id="wait_for_reddit_api",
        poke_interval=60,  # Check every 60 seconds
        timeout=120,  # Fail after 2 minutes
    )

    # Task 2: Fetch latest posts
    fetch_reddit_posts = PythonOperator(
        task_id="fetch_reddit_posts",
        python_callable=fetch_latest_posts,
        op_kwargs={"subreddit_name": "worldnews", "limit": 100},
    )

    # Task 3: Upload data to S3
    upload_to_s3_task = PythonOperator(
        task_id="upload_to_s3",
        python_callable=upload_to_s3,
    )

    # Task 4: Transform data with Pandas
    transform_data_task = PythonOperator(
        task_id="transform_data",
        python_callable=transform_reddit_data,
    )

    load_to_snowflake = PythonOperator(
        task_id="load_to_snowflake",
        python_callable=load_snowflake,
        provide_context=True,
    )

    # Task dependencies
    (
        wait_for_reddit_api
        >> fetch_reddit_posts
        >> upload_to_s3_task
        >> transform_data_task
        >> load_to_snowflake
    )
