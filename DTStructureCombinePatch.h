@interface DTStructureCombinePatch : QCPatch
{
	QCStructurePort *inputStructure1;
	QCStructurePort *inputStructure2;
	QCStructurePort *outputStructure;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
