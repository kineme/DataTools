#import "SpookySendPatch.h"
#import "SpookyReceivePatch.h"

@implementation SpookySendPatch : QCPatch

+ (QCPatchExecutionMode)executionModeWithIdentifier:(id)fp8
{
	return 1;
}

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

- (id)initWithIdentifier:(id)fp8
{	
	if(self = [super initWithIdentifier: fp8])
	{
		[inputSender setStringValue:@"Sender0"];
		[inputAutoClean setBooleanValue: TRUE];
		[[self userInfo] setObject:@"Kineme Spooky Send" forKey:@"name"];
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

- (void)disable:(QCOpenGLContext *)context
{
	[prevSender release];
	prevSender = nil;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	NSString *sender = [inputSender stringValue];
	id object = [inputObject rawValue];
	if([inputAutoClean booleanValue] && prevSender && [sender isEqualToString:prevSender] == FALSE)
		[nexusManager removeObjectForKey:prevSender];
		
	if(object != nil)
	{
//		SLog(@"%@: Sending '%@'",sender,object);
		[nexusManager setValue:object forKey:sender];
	}
		
/*	if(prevSender /*&& [prevSender isEqualTo:[inputSender stringValue]] == FALSE*//*)
		[SpookyIndexPort removeSender:prevSender];

	if([inputObject rawValue] != nil)
		[SpookyIndexPort setObject:[inputObject rawValue] forSender:[inputSender stringValue]];*/

	[prevSender release];
	prevSender = [sender copyWithZone:NULL];

	return YES;
}

@end
