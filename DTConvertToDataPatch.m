#import "DTConvertToDataPatch.h"

@implementation DTConvertToDataPatch
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

-(id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme Serialize Virtual" forKey:@"name"];
	}
	return self;
}

-(BOOL)setup:(QCOpenGLContext*)context
{
	return YES;
}

-(void)cleanup:(QCOpenGLContext*)context
{
}

-(void)enable:(QCOpenGLContext*)context
{
}

-(void)disable:(QCOpenGLContext*)context
{
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	if ([inputObject wasUpdated])
	{
		NSData *data = ([inputObject value] ? [NSArchiver archivedDataWithRootObject:[inputObject value]] : nil); 
		[outputRawData setRawValue:data]; 
	}
	
	return YES;
}

@end
