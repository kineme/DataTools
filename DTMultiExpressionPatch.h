@interface DTMultiExpressionPatch : QCProgrammablePatch
{
	QCStructurePort *outputStructure;

	NSMutableArray *expressions,*resultVariables;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
