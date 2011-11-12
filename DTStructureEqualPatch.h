@interface DTStructureEqualPatch : QCPatch
{
	QCStructurePort *inputStructure1;
	QCStructurePort *inputStructure2;
	QCBooleanPort *outputEquality;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier;
+(int)timeModeWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end

BOOL DTStructureCompare(QCStructure* qcs1, QCStructure* qcs2);
