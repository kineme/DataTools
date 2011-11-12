@interface DTStructurePushPatch : QCPatch
{
	QCStructurePort *inputStructure;
	QCIndexPort *inputDirection;
	QCVirtualPort *inputValue;
	QCBooleanPort *inputPushing;

	QCStructurePort *outputStructure;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
