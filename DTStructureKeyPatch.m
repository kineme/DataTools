#import "DTStructureKeyPatch.h"

@implementation DTStructureKeyPatch

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
		[[self userInfo] setObject:@"Kineme Structure Key" forKey:@"name"];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	if ([inputStructure wasUpdated] || [inputIndex wasUpdated])
	{
		QCStructure *s = [inputStructure structureValue];
		NSUInteger i = [inputIndex indexValue];
		[outputKey setStringValue: [[s _list] keyAtIndex:i]];
	}
	
	return YES;
}

@end
