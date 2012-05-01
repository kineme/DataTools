#import "DTStringToDataPatch.h"

@implementation DTStringToDataPatch

+(BOOL)isSafe
{
	return NO;
}

+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier
{
	return NO;
}

+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier
{
	return kQCPatchExecutionModeProcessor;
}

+(QCPatchTimeMode)timeModeWithIdentifier:(id)identifier
{
	return kQCPatchTimeModeNone;
}

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme String To Data" forKey:@"name"];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	if ([inputString wasUpdated])
	{
		NSData *data = [[inputString stringValue] dataUsingEncoding:NSUTF8StringEncoding];
		[outputRawData setRawValue:data];
		NSLog(@"%@", data);
	}
	
	return YES;
}

@end
