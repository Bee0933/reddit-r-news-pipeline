import logging
from soda.scan import Scan


# Logging config
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)


def check(
    scan_name: str,
    checks_subpath: str = None,
    data_source: str = "reddit_snowflake_source",
    project_root: str = "include",
):
    logging.info("Running Soda scan")

    config_file = f"{project_root}/soda/configuration.yml"
    checks_path = f"{project_root}/soda/checks"

    if checks_subpath:
        checks_path += f"/{checks_subpath}"

    scan = Scan()
    scan.set_verbose()
    scan.add_configuration_yaml_file(config_file)
    scan.set_data_source_name(data_source)
    scan.add_sodacl_yaml_files(checks_path)
    scan.set_scan_definition_name(scan_name)

    result = scan.execute()
    logging.info(scan.get_logs_text())

    if result != 0:
        raise ValueError("soda scan failed!")

    return result
