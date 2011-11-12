@interface DTStructurePopPatch : QCPatch
{
	QCStructurePort *inputStructure;
	QCIndexPort *inputDirection;
	QCBooleanPort *inputPopping;

	QCStructurePort *outputStructure;
	QCVirtualPort *outputValue;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
