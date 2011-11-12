#import "DTStructurePopPatch.h"

@implementation DTStructurePopPatch

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
		[[self userInfo] setObject:@"Structure Pop" forKey:@"name"];

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

	if([inputPopping booleanValue])
	{
		GFList *gfl = [s _list];

		NSUInteger index = 0;
		if([inputDirection indexValue])
			index = [gfl count]-1;

		[outputValue setRawValue:[gfl objectAtIndex:index]];
		[gfl removeObjectAtIndex:index];
	}

	[outputStructure setStructureValue:s];
	[s release];

	return YES;
}

@end
