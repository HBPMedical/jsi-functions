#'
#' Computes the summary statistics.
#' The data are obtained from the local databases using a specific query.
#' This query will be the same for all nodes.
#'
#' Environment variables:
#'
#' - Input Parameters:
#'      PARAM_query  : SQL query producing the dataframe to analyse
#'      PARAM_target_att : Target attribute
#' - Execution context:
#'      JOB_ID : ID of the job
#'      NODE : Node used for the execution of the script
#'      IN_JDBC_DRIVER : class name of the JDBC driver for input data
#'      IN_JDBC_JAR_PATH : path to the JDBC driver jar for input data
#'      IN_JDBC_URL : JDBC connection URL for input data
#'      IN_JDBC_USER : User for the database connection for input data
#'      IN_JDBC_PASSWORD : Password for the database connection for input data
#'      OUT_JDBC_DRIVER : class name of the JDBC driver for output results
#'      OUT_JDBC_JAR_PATH : path to the JDBC driver jar for output results
#'      OUT_JDBC_URL : JDBC connection URL for output results
#'      OUT_JDBC_USER : User for the database connection for output results
#'      OUT_JDBC_PASSWORD : Password for the database connection for output results
#'

library(hbpjdbcconnect);
library(jsonlite);

# Initialisation
target <- Sys.getenv("PARAM_target_att");

# Fetch the data
y <- fetchData();

data_file <- "/tmp/data.json"
write(toJSON(y), file=data_file);

# Perform the computation
tmp_out_file <- "/tmp/out.csv"
system(paste("python", "/src/hedwig/hbp_wrapper.py", data_file, target, tmp_out_file), wait=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE);

# Collect results
out_file <- '/tmp/out.json'
res <- readChar(out_file, file.info(out_file)$size);

# Store results in the database
saveResults(as.data.frame(res), fn = 'r-hedwig');

