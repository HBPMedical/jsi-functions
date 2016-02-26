[Data]
File = mydata.arff
RemoveMissingTarget = Yes

[Attributes]
Target = 21,22,23,24,25,26,27,28,29,30,31,32,33,34
Descriptive = 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20

[Tree]
ConvertToRules = Leaves
Heuristic = VarianceReduction

[Rules]
CoveringMethod = RulesFromTree
PredictionMethod = GDOptimized
OptOmitRulePredictions = Yes
OptGDEarlyStopAmount = 0.333333
OptGDMTGradientCombine = Avg
OptNormalization = Yes
PrintRuleWiseErrors = No
OptGDMaxIter = 100
OptGDNbOfTParameterTry = 11
OptRuleWeightThreshold = 0
ComputeDispersion = No
OptGDGradTreshold = 0.0
OptGDMaxNbWeights = 10
OptLinearTermsTruncate = No
OptDefaultShiftPred = Yes
OptGDEarlyTTryStop = Yes
OptGDEarlyStopTreshold = 1.1
CoveringWeight = 0.1
OptAddLinearTerms = YesSaveMemory
OptAddLinearTerms = Yes
RuleAddingMethod = Always
PrintAllRules = Yes
OptGDIsDynStepsize = Yes
OptGDStepSize = 1

[Constraints]
MaxDepth = 10

[Ensemble]
EnsembleMethod = RForest
Iterations = 100
PrintAllModels = No
EnsembleRandomDepth = Yes

[Output]
OutputJSONModel = Yes
