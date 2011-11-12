#import "DTOrderPatch.h"

@implementation DTOrderPatch

+(BOOL)isSafe
{
	return YES;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier
{
	return kQCPatchExecutionModeProvider;
}

+(QCPatchTimeMode)timeModeWithIdentifier:(id)identifier
{
	return kQCPatchTimeModeNone;
}


-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Order" forKey:@"name"];
	}
	return self;
}

-(void)enable:(QCOpenGLContext*)context
{
	om = [DTOrderManager sharedManager];
}
-(void)disable:(QCOpenGLContext*)context
{
	[om unuse];
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	[outputOrder setIndexValue:
		[om orderForContext:context channel:[inputChannel stringValue] time:time]
	];
	return YES;
}

@end
