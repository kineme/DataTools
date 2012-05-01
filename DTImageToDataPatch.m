#import "DTImageToDataPatch.h"

@implementation DTImageToDataPatch

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
		[[self userInfo] setObject:@"Kineme Image To Data" forKey:@"name"];

		[inputImageFileType setMaxIndexValue:NSJPEG2000FileType];
		[inputImageFileType setIndexValue:NSPNGFileType];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	if ([inputImage wasUpdated] || [inputImageFileType wasUpdated])
	{
		NSBitmapImageFileType imageFileType = [inputImageFileType indexValue];
		NSImage *image = [inputImage value];
		NSArray *representations = [image representations];
		NSData *data = [NSBitmapImageRep representationOfImageRepsInArray:representations
																usingType:imageFileType
															   properties:nil];
		[outputRawData setRawValue:data];
	}
	
	return YES;
}

@end
