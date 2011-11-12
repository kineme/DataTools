#import "SpookyReceivePatch.h"

@implementation SpookyReceivePatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 2;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

/*+ (int)timeModeWithIdentifier:(id)fp8
{
	return 1;
}*/

- (id)initWithIdentifier:(id)fp8
{
	if(self = [super initWithIdentifier: fp8])
	{
		[inputSender setStringValue:@"Sender0"];
		[[self userInfo] setObject:@"Kineme Spooky Receive" forKey:@"name"];
	}

	return self;
}

- (BOOL)setup:(QCOpenGLContext *)context
{
	nexusManager = [DTSpookyNexus sharedNexusManager];
	return YES;
}
- (void)cleanup:(QCOpenGLContext *)context
{
	[nexusManager unuse];
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	[outputOutput setRawValue:[nexusManager objectForKey:[inputSender stringValue]]];
	//[outputOutput setRawValue:[spookySenderObjects objectForKey:[inputSender stringValue]]];

	return YES;
}

@end
