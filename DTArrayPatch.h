@interface DTArrayPatch : QCPatch
{
	NSMutableArray *portArray;

	QCStructurePort *outputArray;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

- (void)addPort;
- (void)trimPorts;

@end
