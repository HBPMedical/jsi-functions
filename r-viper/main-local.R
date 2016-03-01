#
# Builds a set of predictive clustering rules, describing (one or more)  
# target variable(s) with descriptive variables.
# The data are obtained from the local databases using a specific query.
# This query will be the same for all nodes.
# 
# Environment variables:
# 
# - Input Parameters:
#      PARAM_query : SQL query producing the dataframe to analyse
#      PARAM_varnames : Column separated list of variables (target variable) names
#      PARAM_targetname : Name of target variable
#      PARAM_graph_type : Type of chart
#      PARAM_positive_class : Positive class for evaluation (one-versus-all comparison)
#
# - Execution context:
#      JOB_ID : ID of the job
#      NODE : Node used for the execution of the script
#      IN_JDBC_DRIVER : class name of the JDBC driver for input data
#      IN_JDBC_JAR_PATH : path to the JDBC driver jar for input data
#      IN_JDBC_URL : JDBC connection URL for input data
#      IN_JDBC_USER : User for the database connection for input data
#      IN_JDBC_PASSWORD : Password for the database connection for input data
#      OUT_JDBC_DRIVER : class name of the JDBC driver for output results
#      OUT_JDBC_JAR_PATH : path to the JDBC driver jar for output results
#      OUT_JDBC_URL : JDBC connection URL for output results
#      OUT_JDBC_USER : User for the database connection for output results
#      OUT_JDBC_PASSWORD : Password for the database connection for output results
#

#library(hbpjdbcconnect);
library(jsonlite);
library(foreign);

# Fetch the data and store it in a json file
#mydata <- fetchData();
mydata <- read.csv("mydata.csv");
data_file <- "data.json";
out_file <- "data_out.json";
graph_type <- "rocc";
positive_class <- "CN";
write(toJSON(mydata), file=data_file);

system(paste("python", "hbp_wrapper.py --input_file ", data_file, "--output_file ", out_file,  "--class_column", targetname, "--descriptive_columns", gsub(",", " ", varnames), "--graph_type", graph_type, "--positive_class", positive_class), wait=TRUE, ignore.stdout=FALSE, ignore.stderr=FALSE);

# Collect results
res <- readChar(out_file, file.info(out_file)$size);

# Store results in the database
# saveResults(as.data.frame(res), fn = 'r-tehin');
