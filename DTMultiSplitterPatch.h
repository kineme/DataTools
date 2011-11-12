@interface DTMultiSplitterPatch : QCPatch
{
	NSMutableArray *inPorts;	// QCPorts
	NSMutableArray *outPorts;	// QCPorts
	NSMutableArray *max, *min;	// NSNumbers
	NSMutableArray *labels; // NSNull unless the port actually has labels
}

@property (readonly,assign) NSUInteger portCount;

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
+(int)executionModeWithIdentifier:(id)identifier;
+(int)timeModeWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(id)nodeActorForView:(NSView*)view;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;
-(NSDictionary*)state;
-(BOOL)setState:(NSDictionary*)state;

@end
