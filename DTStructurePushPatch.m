#import "DTStructurePushPatch.h"

@implementation DTStructurePushPatch

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
		[[self userInfo] setObject:@"Structure Push" forKey:@"name"];

		[inputDirection setMaxIndexValue:1];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	QCStructure *s, *is = [inputStructure structureValue];
	if(is)
		s = [[QCStructure alloc] initWithStructure:[inputStructure structureValue]];
	else
		s = [[QCStructure alloc] init];

	if([inputPushing booleanValue])
	{
		GFList *gfl = [s _list];

		NSUInteger index = 0;
		if([inputDirection indexValue])
			index = [gfl count];

		[gfl insertObject:[inputValue value] atIndex:index forKey:nil];
	}

	[outputStructure setStructureValue:s];
	[s release];

	return YES;
}

@end
