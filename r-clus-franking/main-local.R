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
#      PARAM_varnames : Column separated list of variables
#                       (target variable) names
#      PARAM_covarnames : Column separated list of covariables
#                         (descriptive variables) names
#      PARAM_Iterations : Number of base predictive models in the ensemble
#      PARAM_EnsembleMethod : Type of ensemble method: RForest or ExtraTrees
#      PARAM_FeatureRanking : Type of feature ranking method: RForest or GENIE3
#      PARAM_SelectRandomSubspaces : The feature subset size to be considered at each node:
#					if the value is integer, then it is the absolute number of variables (e.g., 5 means consider 5 variables),
#					if the value is double, then it is the relative number of variables (e.g., 0.1 means consider 10% of the variables), 
#					sqrt considers the sqrt rounded up of the number of available variables,
#					log considers the log rounded up of the number of available variables,  
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
library(foreign);

# Initialisation
initial_wd <- getwd();
#varnames <- Sys.getenv("PARAM_varnames");
varnames <- "EcogPtMem_bl,EcogPtLang_bl,EcogPtwisspat_bl,EcogPtPlan_bl,EcogPtOrgan_bl,EcogPtDiwatt_bl,EcogPtTotal_bl,EcogSPMem_bl,EcogSPLang_bl,EcogSPwisspat_bl,EcogSPPlan_bl,EcogSPOrgan_bl,EcogSPDiwatt_bl,EcogSPTotal_bl";

#covarnames <- Sys.getenv("PARAM_covarnames");
covarnames <- "APOE4,wentricles_bl,Hippocampus_bl,WholeBrain_bl,Entorhinal_bl,Fusiform_bl,MidTemp_bl,ICw_bl,FDG_bl,Aw45_bl,CDRSB_bl,ADAS13_bl,MMSE_bl,RAwLT_immediate_bl,RAwLT_learning_bl,RAwLT_forgetting_bl,RAwLT_perc_forgetting_bl,FAQ_bl,MOCA_bl";


#number of iterations
#nbIterations <- Sys.getenv("PARAM_Iterations");
nbIterations <- 100;

#ensemble method
#ensemble_method <- Sys.getenv("PARAM_EnsembleMethod");
ensemble_method <- "RForest";

#ranking method
#ranking_type <- Sys.getenv("PARAM_FeatureRanking");
ranking_type <- "GENIE3";

#number of subspaces considered for Random forests and Extra trees
#nbSubspaces <- Sys.getenv("PARAM_SelectRandomSubspaces");
nbSubspaces <- 0.1;

# Fetch the data and store it in an arff file
#mydata <- fetchData();
mydata <- read.csv("mydata.csv");
write.arff(mydata, "mydata.arff", eol = "\n", relation = "mydata");

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
	
settingsEnsemble <- c(
	"\n[Ensemble]",
	paste("EnsembleMethod = ", ensemble_method, sep=""),
	paste("Iterations = ", toString(nbIterations), sep=""),
	"PrintAllModels = No",
	paste("FeatureRanking = ", ranking_type, sep=""),
	paste("SelectRandomSubspaces = ", toString(nbSubspaces), sep=""));
	
settingsOutput <- c(
	"\n[Output]",
	"OutputJSONModel = Yes");
	
writeLines(settingsData, setFile);
writeLines(settingsAttributes, setFile);
writeLines(settingsTree, setFile);
writeLines(settingsEnsemble,setFile);
writeLines(settingsOutput,setFile);

close(setFile);

# Perform the computation
system("java -jar Clus.jar -forest mydata.s", wait=TRUE, ignore.stdout=TRUE, ignore.stderr=FALSE);

# Collect results
#resFile <- file("mydata.json", open="r");
#res <- readLines(resFile);


