#import "DTStructureCombinePatch.h"

@implementation DTStructureCombinePatch
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
		[[self userInfo] setObject:@"Kineme Structure Combine" forKey:@"name"];
	}
	return self;
}

-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments
{
	QCStructure *is1 = [inputStructure1 structureValue];
	QCStructure *is2 = [inputStructure2 structureValue];

	QCStructure *outStructure;
	if(is1)
	{
		outStructure = [[QCStructure allocWithZone:NULL] initWithStructure:is1];
		GFList *osl = [outStructure _list];
		GFList *is2l = [[inputStructure2 structureValue] _list];
		@try
		{
			[osl addEntriesFromList:is2l];
		}
		@catch(NSException *e)
		{
			// probably failed because there are duplicate keys in the list.  try adding manually.
			NSUInteger i;
			for(i=0;i<[is2l count];++i)
				if([osl indexOfKey:[is2l keyAtIndex:i]] == NSNotFound)
					[osl addObject:[is2l objectAtIndex:i] forKey:[is2l keyAtIndex:i]];
				else
					[osl setObject:[is2l objectAtIndex:i] forKey:[is2l keyAtIndex:i]];
		}
	}
	else
	{
		if(is2)
			outStructure = [[QCStructure alloc] initWithStructure:is2];
		else
			outStructure = [[QCStructure alloc] init];
	}
	[outputStructure setStructureValue:outStructure];
	[outStructure release];

	return YES;
}

@end
