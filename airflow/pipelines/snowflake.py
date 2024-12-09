import logging
import pandas as pd
from sqlalchemy import create_engine
from airflow.models import Variable

# Logging config
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)

SNOWFLAKE_USER = Variable.get("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = Variable.get("SNOWFLAKE_PASSWORD")
SNOWFLAKE_ACCOUNT = Variable.get("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_WAREHOUSE = Variable.get("SNOWFLAKE_WAREHOUSE")
SNOWFLAKE_DATABASE = Variable.get("SNOWFLAKE_DATABASE")
SNOWFLAKE_STG_SCHEMA = Variable.get("SNOWFLAKE_STG_SCHEMA")
SNOWFLAKE_STG_TABLENAME = Variable.get("SNOWFLAKE_STG_TABLENAME")
SNOWFLAKE_ANALYTICS_SCHEMA = Variable.get("SNOWFLAKE_ANALYTICS_SCHEMA")
SNOWFLAKE_ANALYTICS_TABLENAME = Variable.get("SNOWFLAKE_ANALYTICS_TABLENAME")


# Snowflake connection details
snowflake_config = {
    "user": SNOWFLAKE_USER,
    "password": SNOWFLAKE_PASSWORD,
    "account": SNOWFLAKE_ACCOUNT,
    "warehouse": SNOWFLAKE_WAREHOUSE,
    "database": SNOWFLAKE_DATABASE,
    "schema": SNOWFLAKE_STG_SCHEMA,
}


def get_engine():
    return create_engine(
        f"snowflake://{snowflake_config['user']}:{snowflake_config['password']}@"
        f"{snowflake_config['account']}/{snowflake_config['database']}/{snowflake_config['schema']}?"
        f"warehouse={snowflake_config['warehouse']}"
    )


def load_snowflake(**kwargs):
    ti = kwargs["ti"]
    parquet_file_path = ti.xcom_pull(
        key="transformed_parquet_file_path", task_ids="transform_data"
    )
    if not parquet_file_path:
        raise ValueError("No Parquet file path found in XCom!")

    df = pd.read_parquet(parquet_file_path)
    engine = get_engine()

    # Append the data to the Snowflake table
    table_name = SNOWFLAKE_STG_TABLENAME
    try:
        df.to_sql(
            name=table_name,
            schema=snowflake_config["schema"],
            con=engine,
            if_exists="append",
            index=False,
        )
        print(
            f"Successfully appended {len(df)} rows to {snowflake_config['schema']}.{table_name}"
        )
    except Exception as e:
        raise ValueError(f"Failed to load data into Snowflake: {e}")
    finally:
        engine.dispose()


def process_and_store_in_analytics(**kwargs):
    engine = get_engine()
    try:
        query = f"SELECT * FROM {SNOWFLAKE_STG_SCHEMA}.{SNOWFLAKE_STG_TABLENAME}"
        df = pd.read_sql(query, engine)

        columns_to_drop = ['selftext']
        df_filtered = df.drop(columns=columns_to_drop, errors='ignore')

        with engine.connect() as connection:
            connection.execute(f"CREATE SCHEMA IF NOT EXISTS {SNOWFLAKE_ANALYTICS_SCHEMA};")

        df_filtered.to_sql(
            name=SNOWFLAKE_ANALYTICS_TABLENAME,
            schema=SNOWFLAKE_ANALYTICS_SCHEMA,
            con=engine,
            if_exists="append",
            index=False,
        )

        logging.info(f"Data successfully processed and stored in {SNOWFLAKE_ANALYTICS_SCHEMA}.{SNOWFLAKE_ANALYTICS_TABLENAME}")

    except Exception as e:
        logging.error(f"Failed to process and store data: {e}")
        raise
    finally:
        engine.dispose()
