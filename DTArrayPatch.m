#import "DTArrayPatch.h"


static bool DTArrayPortIsSettingState(void)
{
	// @@@ surely there's a better way to detect this...
	for(NSString *frame in [NSThread callStackSymbols])
		if(
			[frame rangeOfString:@"-[QCPatch(Override) setState:]"].location != NSNotFound		// open composition
			|| [frame rangeOfString:@"-[GFGraph(Private) _loadState:]"].location != NSNotFound	// paste from clipboard
			)
			return YES;

	return NO;
}


@interface DTArrayPort : QCVirtualPort
@end

@implementation DTArrayPort

- (void)_setConnectedPort:(QCPort *)port
{
	// only add ports if the connection is happening live in the editor (not when restoring composition state)
	if(!DTArrayPortIsSettingState())
		if(port)
			[(DTArrayPatch *)[self parentPatch] addPort];
		else
			[(DTArrayPatch *)[self parentPatch] trimPorts];

	[super _setConnectedPort:port];
}

- (void)_setProxyPort:(QCPort *)port
{
	// only add ports if the connection is happening live in the editor (not when restoring composition state)
	if(!DTArrayPortIsSettingState())
		if(port)
			[(DTArrayPatch *)[self parentPatch] addPort];
		else
			[(DTArrayPatch *)[self parentPatch] trimPorts];

	[super _setProxyPort:port];
}

@end


@implementation DTArrayPatch

- (void)addPort
{
	[portArray addObject:
		[self createInputWithPortClass:[DTArrayPort class] forKey:[NSString stringWithFormat:@"%i",[portArray count]] attributes:nil]
	];
}

// remove unused ports from the end, leaving just one spare port
- (void)trimPorts
{
	while(1)
	{
		NSString *k = [NSString stringWithFormat:@"%i",[portArray count]-1];
		QCPort *p = (QCPort *)[self portForPath:k];
		if([p connectedPort] || [p proxyPort])
			break;
		[self deleteInputForKey:k];
		[portArray removeLastObject];
	}

	[self addPort];
}



+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Array" forKey:@"name"];

		portArray = [[NSMutableArray alloc] init];
		[self addPort];
	}
	return self;
}

- (void)dealloc
{
	[portArray release];
	[super dealloc];
}



-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	QCStructure *s = [[QCStructure alloc] init];
	GFList *l = [s _list];
	for(NSUInteger i=0;i<[[self inputPorts] count]-1;++i)
	{
		id v = [[[self inputPorts] objectAtIndex:i] value];
		[l insertObject:v?v:[NSArray array] atIndex:i forKey:nil];
	}
	[outputArray setStructureValue:s];
	[s release];

	return YES;
}





- (NSDictionary*)state
{
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] initWithCapacity:2];
	[stateDict addEntriesFromDictionary:[super state]];
	
	[stateDict setObject:[NSNumber numberWithInt:[portArray count]-1] forKey:@"arrayCount"];

	[stateDict autorelease];
	return stateDict;
}
- (BOOL)setState:(NSDictionary*)state
{
	for(NSUInteger i=[portArray count];i<=[[state objectForKey:@"arrayCount"] intValue];++i)
		[self addPort];

	return [super setState:state];
}

@end
