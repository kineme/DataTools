#import "DTStructureEqualPatch.h"

BOOL DTStructureCompare(QCStructure* qcs1, QCStructure* qcs2)
{
	NSUInteger i, count1;

	if(qcs1 == qcs2)
		return YES;

	count1 = [qcs1 count];

	if(count1 != [qcs2 count])
		return NO;
	
	Class QCStructureClass = [QCStructure class];

	for(i=0; i < count1; i++)
	{
		if([[qcs1 keyAtIndex:i] compare:[qcs2 keyAtIndex:i]] != 0)
			return NO;

		id member1 = [qcs1 memberAtIndex:i];
		id member2 = [qcs2 memberAtIndex:i];
		if([member1 class] != [member2 class])
			return NO;

		if([member1 respondsToSelector:@selector(compare:)])
		{
			if([member1 compare:member2] != 0)
				return NO;
			else
				continue;
		}
		
		if([member1 isKindOfClass:QCStructureClass])
		{
			if(!DTStructureCompare(member1, member2))
				return NO;
			else
				continue;
		}
		else
		{
			// FIXME: Colors, Images, and Meshes might end up here -- handle someday
			NSLog(NSLocalizedString(@"DTStructureEqualPatch WARNING: encountered unexpected class in a QCStructure: %@ (%@) ...comparison returned false by default.",@""), member1, [member1 className]);
			return NO;
		}
	}
	
	return YES;	
}



@implementation DTStructureEqualPatch

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
	return 0;
}

+(int)timeModeWithIdentifier:(id)identifier
{
	return 0;
}

- (id)initWithIdentifier:(id)identifier
{
	if(self = [super initWithIdentifier:identifier])
	{
		[[self userInfo] setObject:@"Kineme Structure Equal" forKey:@"name"];
		[outputEquality setBooleanValue:TRUE];
	}
	return self;
}

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	[outputEquality setBooleanValue:DTStructureCompare([inputStructure1 structureValue], [inputStructure2 structureValue])];
	return YES;
}

@end
