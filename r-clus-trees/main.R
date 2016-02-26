#
# Builds a set of predictive clustering trees, describing (one or more)  
# target variable(s) with descriptive variables.
# The data are obtained from the local databases using a specific query.
# This query will be the same for all nodes.
# 
# Environment variables:
# 
# - Input Parameters:
#      PARAM_query : SQL query producing the dataframe to analyse
#      PARAM_varnames : Column separated list of variables
#                       (target variable) names
#      PARAM_covarnames : Column separated list of covariables
#                         (descriptive variables) names
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

library(hbpjdbcconnect);
library(foreign);

# Initialisation
initial_wd <- getwd();
varnames <- Sys.getenv("PARAM_varnames");
covarnames <- Sys.getenv("PARAM_covarnames");

# Fetch the data and store it in an arff file
mydata <- fetchData();
write.arff(mydata, "mydata.arff", eol = "\n", relation = "mydata");

# Get query information and store it into query.param file
queryFile<-file("query.param")
writeLines(Sys.getenv("PARAM_query"), queryFile)
close(queryFile)

# Assemble the Clus settings file
target_atts <- match(unlist(strsplit(varnames, ",")), names(mydata));
descriptive_atts <- match(unlist(strsplit(covarnames, ",")), names(mydata));
target_atts_list <- paste(target_atts, collapse=",");
descriptive_atts_list <- paste(descriptive_atts, collapse=",");

setFile <- file("mydata.s", open="w");

# setting file sections
settingsData <- c(
	"[Data]",
	"File = mydata.arff",
	"RemoveMissingTarget = Yes");
	
settingsAttributes <- c(
	"\n[Attributes]",
	paste("Target =", target_atts_list, collapse=""),
	paste("Descriptive =", descriptive_atts_list, collapse=""));

settingsTree <- c(
	"\n[Tree]",
	"Heuristic = VarianceReduction");

settingsOutput <- c(
	"\n[Output]",
	"OutputJSONModel = Yes");
	
writeLines(settingsData, setFile);
writeLines(settingsAttributes, setFile);
writeLines(settingsTree, setFile);
writeLines(settingsOutput,setFile);

close(setFile);

# Perform the computation
system("java -jar Clus.jar mydata.s", wait=TRUE, ignore.stdout=TRUE, ignore.stderr=FALSE);

# Collect results
resFile <- file("mydata.json", open="r");
res <- readLines(resFile);

# Store results in the database
saveResults(res);

