@interface DTDataCombinePatch : QCPatch
{
	QCVirtualPort *inputRawData1;
	QCVirtualPort *inputRawData2;
	QCVirtualPort *outputRawData;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier;
+(QCPatchTimeMode)timeModeWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
