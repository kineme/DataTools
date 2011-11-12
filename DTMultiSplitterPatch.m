#import "DTMultiSplitterPatch.h"
#import "DTMultiSplitterPatchUI.h"

@implementation DTMultiSplitterPatch
+(BOOL)isSafe
{
	return NO;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

+(int)executionModeWithIdentifier:(id)identifier
{
	return 0;
}

+(int)timeModeWithIdentifier:(id)identifier
{
	return 0;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [DTMultiSplitterPatchUI class];
}

-(NSUInteger)portCount
{
	return [inPorts count];
}

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme MultiSplitter" forKey:@"name"];
	}
	return self;
}

-(id)nodeActorForView:(NSView*)view
{
	if(KIOnSnowLeopard())
	{
		Class QCMiniPatchActor = objc_getClass("QCMiniPatchActor");
		return [QCMiniPatchActor sharedActor];
	}
	else	// not 10.6 -- nothing fancy FIXME: update for 10.7
		return [super nodeActorForView:view];
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	return YES;
}

-(NSDictionary*)state
{
	return [super state];
}

-(BOOL)setState:(NSDictionary*)state
{
	return [super setState:state];
}

@end
