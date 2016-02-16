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

# Initialisation
initial_wd <- getwd();
#varnames <- Sys.getenv("PARAM_varnames");
varnames <- "DX";

#covarnames <- Sys.getenv("PARAM_covarnames");
covarnames <- "APOE4,wentricles_bl,Hippocampus_bl,WholeBrain_bl,Entorhinal_bl,Fusiform_bl,MidTemp_bl,ICw_bl,FDG_bl,Aw45_bl,CDRSB_bl,ADAS13_bl,MMSE_bl,RAwLT_immediate_bl,RAwLT_learning_bl,RAwLT_forgetting_bl,RAwLT_perc_forgetting_bl,FAQ_bl,MOCA_bl,EcogPtMem_bl,EcogPtLang_bl,EcogPtwisspat_bl,EcogPtPlan_bl,EcogPtOrgan_bl,EcogPtDiwatt_bl,EcogPtTotal_bl,EcogSPMem_bl,EcogSPLang_bl,EcogSPwisspat_bl,EcogSPPlan_bl,EcogSPOrgan_bl,EcogSPDiwatt_bl,EcogSPTotal_bl";

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
	"ConvertToRules = Leaves",
	"Heuristic = VarianceReduction");

settingsRules <- c(
	"\n[Rules]",
	"CoveringMethod = RulesFromTree",
	"PredictionMethod = GDOptimized",
	"OptOmitRulePredictions = Yes",
	"OptGDEarlyStopAmount = 0.333333",
	"OptGDMTGradientCombine = Avg",
	"OptNormalization = Yes",
	"PrintRuleWiseErrors = No",
	"OptGDMaxIter = 100",
	"OptGDNbOfTParameterTry = 11",
	"OptRuleWeightThreshold = 0",
	"ComputeDispersion = No",
	"OptGDGradTreshold = 0.0",
	"OptGDMaxNbWeights = 100",
	"OptLinearTermsTruncate = No",
	"OptDefaultShiftPred = Yes",
	"OptGDEarlyTTryStop = Yes",
	"OptGDEarlyStopTreshold = 1.1",
	"CoveringWeight = 0.1",
	"OptAddLinearTerms = YesSaveMemory",
	"OptAddLinearTerms = Yes",
	"RuleAddingMethod = Always",
	"PrintAllRules = Yes",
	"OptGDIsDynStepsize = Yes",
	"OptGDStepSize = 1");

settingsConstraints <- c(
	"\n[Constraints]",
	"MaxDepth = 10");
	
settingsEnsemble <- c(
	"\n[Ensemble]",
	"EnsembleMethod = RForest",
	"Iterations = 100",
	"PrintAllModels = No",
	"EnsembleRandomDepth = Yes");
	
writeLines(settingsData);
writeLines(settingsAttributes);
writeLines(settingsTree);
writeLines(settingsRules, setFile);
writeLines(settingsConstraints, setFile);
writeLines(settingsEnsemble,setFile);





close(setFile);

# Perform the computation
system("java -jar Clus.jar -rules mydata.s", wait=TRUE, ignore.stdout=TRUE, ignore.stderr=FALSE);

# Collect results
resFile <- file("model.json", open="r");
res <- readLines(resFile);

# Store results in the database
#saveResults(res);
