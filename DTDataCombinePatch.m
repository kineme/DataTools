#import "DTDataCombinePatch.h"

@implementation DTDataCombinePatch

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
		[[self userInfo] setObject:@"Kineme Data Combine" forKey:@"name"];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	if ([inputRawData1 wasUpdated] || [inputRawData2 wasUpdated])
	{
		NSData *data1 = [inputRawData1 rawValue];
		NSData *data2 = [inputRawData2 rawValue];
		NSMutableData *d = [NSMutableData dataWithCapacity:[data1 length]+[data2 length]];
		[d appendData:data1];
		[d appendData:data2];
		[outputRawData setRawValue:d];
	}
	
	return YES;
}

@end
