import logging, praw, boto3, io
import pandas as pd
from airflow.sensors.base import BaseSensorOperator
from datetime import datetime, timedelta, timezone
from airflow.models import Variable


# Logging config
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)

REDDIT_CLIENT_ID = Variable.get("REDDIT_CLIENT_ID")
REDDIT_CLIENT_SECRET = Variable.get("REDDIT_CLIENT_SECRET")
REDDIT_USERNAME = Variable.get("REDDIT_USERNAME")
REDDIT_PASSWORD = Variable.get("REDDIT_PASSWORD")
S3_BUCKET = Variable.get("S3_BUCKET")
SPACES_S3_KEY = Variable.get("SPACES_S3_KEY")
SPACES_S3_SECRET = Variable.get("SPACES_S3_SECRET")

# Reddit API configuration
REDDIT_CONFIG = {
    "user_agent": True,
    "client_id": REDDIT_CLIENT_ID,
    "client_secret": REDDIT_CLIENT_SECRET,
    "username": REDDIT_USERNAME,
    "password": REDDIT_PASSWORD,
}

# Custom Reddit Sensor
class RedditAPISensor(BaseSensorOperator):
    def poke(self, context):
        reddit = praw.Reddit(**REDDIT_CONFIG)
        try:
            subreddit = reddit.subreddit("worldnews")
            # Test if the subreddit can be accessed
            list(subreddit.new(limit=1))
            return True
        except Exception as e:
            self.log.info(f"Reddit API not available yet: {e}")
            return False


# Function to fetch and save latest posts
def fetch_latest_posts(**kwargs):
    reddit = praw.Reddit(**REDDIT_CONFIG)
    subreddit_name = kwargs.get("subreddit_name", "worldnews")
    limit = kwargs.get("limit", 100)

    subreddit = reddit.subreddit(subreddit_name)
    three_hours_ago = datetime.now(timezone.utc) - timedelta(hours=3)

    posts = [
        {
            "id": submission.id,
            "title": submission.title,
            "selftext": submission.selftext,
            "created_utc": datetime.fromtimestamp(submission.created_utc).strftime(
                "%Y-%m-%dT%H:%M:%SZ"
            ),
            "subreddit": str(submission.subreddit),
            "subreddit_id": submission.subreddit_id,
            "link_flair_text": submission.link_flair_text,
            "link_flair_css_class": submission.link_flair_css_class,
            "url": submission.url,
            "is_self": submission.is_self,
            "over_18": submission.over_18,
            "spoiler": submission.spoiler,
            "upvote_ratio": submission.upvote_ratio,
            "ups": submission.ups,
            "downs": submission.downs,
            "score": submission.score,
            "num_comments": submission.num_comments,
            "author": str(submission.author),
            "author_fullname": submission.author_fullname,
            "is_video": submission.is_video,
            "permalink": f"https://www.reddit.com{submission.permalink}",
        }
        for submission in subreddit.new(limit=limit)
        if datetime.fromtimestamp(submission.created_utc, tz=timezone.utc)
        > three_hours_ago
    ]

    df = pd.DataFrame(posts)
    # Push DataFrame to XCom as JSON (convert it to dict first)
    kwargs["ti"].xcom_push(key="raw_data", value=df.to_dict(orient="records"))
    


def upload_to_s3(**kwargs):
    # Pull data from XCom
    ti = kwargs["ti"]
    raw_data = ti.xcom_pull(key="raw_data", task_ids="fetch_reddit_posts")

    if not raw_data:
        raise ValueError("No data found in XCom!")

    # Convert back to DataFrame
    df = pd.DataFrame(raw_data)

    # Save to in-memory buffer
    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, index=False)
    parquet_buffer.seek(0)

    current_time = datetime.now()
    formatted_time = current_time.strftime("%Y-%m-%d-%H:%M:%S")
    s3_key = f"r_worldnews_{formatted_time}.parquet"

    # Upload to S3
    s3 = boto3.client(
        "s3",
        endpoint_url="https://reddit-news-lake.fra1.digitaloceanspaces.com",
        aws_access_key_id=SPACES_S3_KEY,
        aws_secret_access_key=SPACES_S3_SECRET,
    )
    s3.upload_fileobj(parquet_buffer, S3_BUCKET, s3_key)
    print(f"File uploaded to s3://{S3_BUCKET}/{s3_key}")


def transform_reddit_data(**kwargs):
    ti = kwargs["ti"]
    raw_data = ti.xcom_pull(key="raw_data", task_ids="fetch_reddit_posts")
    if not raw_data:
        raise ValueError("No data found in XCom!")
    df = pd.DataFrame(raw_data)

    df["selftext"] = df["selftext"].fillna("")
    df["link_flair_text"] = df["link_flair_text"].fillna("No flair")
    df["link_flair_css_class"] = df["link_flair_css_class"].fillna("No Class")
    df["author"] = df["author"].fillna("Unknown Author")
    df.drop_duplicates(subset=["id"], inplace=True)
    df["created_utc"] = pd.to_datetime(df["created_utc"])
    df["created_utc"] = df["created_utc"].dt.date
    df = df[df["over_18"] == False]

    current_time = datetime.now()
    formatted_time = current_time.strftime("%Y-%m-%d-%H:%M:%S")
    save_fmt = f"r_worldnews_{formatted_time}.parquet"

    tmp_path = f"/tmp/{save_fmt}"
    df.to_parquet(tmp_path, engine="pyarrow")  # or 'fastparquet'
    ti.xcom_push(key="transformed_parquet_file_path", value=tmp_path)
    print(f"Transformed Parquet file saved at {tmp_path}, and path pushed to XCom.")
