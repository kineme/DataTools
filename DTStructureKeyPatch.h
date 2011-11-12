@interface DTStructureKeyPatch : QCPatch
{
	QCStructurePort *inputStructure;
	QCIndexPort *inputIndex;
	QCStringPort *outputKey;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
