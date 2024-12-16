################## DATABASE ################

# Create Database
resource "snowflake_database" "reddit_database" {
  name         = var.snowflake_db_name
  comment      = "Database for Reddit API"
  is_transient = false
  log_level    = "INFO"
}

# create schema
resource "snowflake_schema" "reddit_schema" {
  name     = var.reddit_schema_name
  database = snowflake_database.reddit_database.name
}


################## AIRFLOW ################

# Create airflow Role
resource "snowflake_account_role" "airflow_role" {
  name    = "AIRFLOW_ROLE"
  comment = "Airflow Role on snowflake"
}

# Grant DB usage to Airflow Role
resource "snowflake_grant_privileges_to_account_role" "airflow_database_grant" {
  account_role_name = snowflake_account_role.airflow_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.reddit_database.name
  }
  all_privileges    = true
  with_grant_option = true
}

# Grant schema USAGE to Airflow Role
resource "snowflake_grant_privileges_to_account_role" "airflow_schema_usage_grant" {
  account_role_name = snowflake_account_role.airflow_role.name
  on_schema {
    all_schemas_in_database = snowflake_database.reddit_database.name
  }
  all_privileges    = true
  with_grant_option = true
}

# create warehouse for Airflow
resource "snowflake_warehouse" "airflow_warehouse" {
  name                = "AIRFLOW_WAREHOUSE"
  comment             = "Airflow Snowflake Warehouse"
  warehouse_size      = "LARGE"
  auto_resume         = "true"
  auto_suspend        = 120
  initially_suspended = true
}

# Grant access to warehouse to airflow role
resource "snowflake_grant_privileges_to_account_role" "airflow_warehouse_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.airflow_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.airflow_warehouse.name
  }
}

# create airflow user
resource "snowflake_user" "airflow_user" {
  name              = "AIRFLOW_USER"
  default_warehouse = snowflake_warehouse.airflow_warehouse.name
  default_role      = snowflake_account_role.airflow_role.name
  default_namespace = snowflake_database.reddit_database.name
  password          = var.airflow_user_password
}

# Grant role access to airflow user 
resource "snowflake_grant_privileges_to_account_role" "airflow_user_grant" {
  # privileges        = ["MONITOR"]
  account_role_name = snowflake_account_role.airflow_role.name
  on_account_object {
    object_type = "USER"
    object_name = snowflake_user.airflow_user.name
  }
  always_apply      = true
  all_privileges    = true
  with_grant_option = true
}

resource "snowflake_grant_account_role" "airflow_grants" {
  role_name = snowflake_account_role.airflow_role.name
  user_name = snowflake_user.airflow_user.name
}

################## LOOKER ###############

# Create Looker Role
resource "snowflake_account_role" "looker_role" {
  name    = "LOOKER_ROLE"
  comment = "Looker Role on snowflake"
}

# Grant DB usage to Looker Role
resource "snowflake_grant_privileges_to_account_role" "looker_database_grant" {
  account_role_name = snowflake_account_role.looker_role.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.reddit_database.name
  }
  all_privileges    = true
  with_grant_option = true
}

# Grant schema USAGE to Looker Role
resource "snowflake_grant_privileges_to_account_role" "looker_schema_usage_grant" {
  account_role_name = snowflake_account_role.looker_role.name
  on_schema {
    all_schemas_in_database = snowflake_database.reddit_database.name
  }
  all_privileges    = true
  with_grant_option = true
}

# create warehouse for Looker
resource "snowflake_warehouse" "looker_warehouse" {
  name                = "LOOKER_WAREHOUSE"
  comment             = "Looker Snowflake Warehouse"
  warehouse_size      = "SMALL"
  auto_resume         = "true"
  auto_suspend        = 120
  initially_suspended = true
}

# Grant access to warehouse to Looker role
resource "snowflake_grant_privileges_to_account_role" "looker_warehouse_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.looker_role.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.looker_warehouse.name
  }
}

# create looker user
resource "snowflake_user" "looker_user" {
  name              = "LOOKER_USER"
  default_warehouse = snowflake_warehouse.looker_warehouse.name
  default_role      = snowflake_account_role.looker_role.name
  default_namespace = snowflake_database.reddit_database.name
  password          = var.looker_user_password
}

# Grant role access to Looker user 
resource "snowflake_grant_privileges_to_account_role" "looker_user_grant" {
  # privileges        = ["MONITOR"]
  account_role_name = snowflake_account_role.looker_role.name
  on_account_object {
    object_type = "USER"
    object_name = snowflake_user.looker_user.name
  }
  always_apply      = true
  all_privileges    = true
  with_grant_option = true
}

resource "snowflake_grant_account_role" "looker_grants" {
  role_name = snowflake_account_role.looker_role.name
  user_name = snowflake_user.looker_user.name
}