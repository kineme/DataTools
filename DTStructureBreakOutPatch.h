@interface DTStructureBreakOutPatch : QCPatch
{
	QCStructurePort *inputStructure;

	QCVirtualPort *outputConfigure;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

-(void)configureFromInput;

@end
