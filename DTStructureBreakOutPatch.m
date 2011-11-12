#import "DTStructureBreakOutPatch.h"
#import "DTStructureBreakOutPatchUI.h"

#import <objc/runtime.h>

@implementation DTStructureBreakOutPatch

+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [DTStructureBreakOutPatchUI class];
}


-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Structure Breakout" forKey:@"name"];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	GFList *gfl = [[inputStructure structureValue] _list];

	// try to find a value for each output port as best we can
	for(QCVirtualPort *p in [self customOutputPorts])
	{
		id o = [gfl objectForKey:[p key]];
		if(!o)
			o = [gfl objectAtIndex:[[p key] integerValue]];

		[p setRawValue:o];
	}

	return YES;
}

-(void)configureFromInput
{
	// there's no way we'll have valid structure data if we're not rendering, so prevent the user from obliterating everything.
	if(![self isRendering])
		return;


	GFList *gfl = [[inputStructure structureValue] _list];
	NSUInteger i;

	for(QCPort *p in [self customOutputPorts])
		[self deleteOutputPortForKey:[p key]];

	for(i=0;i<[gfl count];++i)
	{
		NSString *key = [gfl keyAtIndex:i];
		if(!key)
			key = [NSString stringWithFormat:@"%d",i];

		if(![self portForKey:key])
			[self createOutputWithPortClass:[QCVirtualPort class] forKey:key attributes:nil];
	}
}


- (NSDictionary*)state
{
	NSUInteger ports = [[self customOutputPorts] count];
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] initWithCapacity:2];
	[stateDict addEntriesFromDictionary:[super state]];

	NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:ports];
	for(QCPort *p in [self customOutputPorts])
		[a addObject:[p key]];
	[stateDict setObject:a forKey:@"outputPortNames"];
	[a release];

	[stateDict autorelease];
	return stateDict;
}
- (BOOL)setState:(NSDictionary*)state
{
	for(QCPort *p in [self customOutputPorts])
		[self deleteOutputPortForKey:[p key]];

	for(NSString *portKey in [state objectForKey:@"outputPortNames"])
		[self createOutputWithPortClass:[QCVirtualPort class] forKey:portKey attributes:nil];

	return [super setState:state];
}

@end
