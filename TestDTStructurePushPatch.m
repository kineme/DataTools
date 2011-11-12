#import "SkankySDK/SkankySDK-TestCase.h"

#import "DTStructurePushPatch.h"


@interface TestDTStructurePushPatch : SkankySDK_TestCase
@end

@implementation TestDTStructurePushPatch

- (void)testStructurePush
{
	DTStructurePushPatch *p = [[DTStructurePushPatch alloc] initWithIdentifier:nil];
	GHAssertNotNil(p,@"");

	[[p valueForKey:@"inputValue"] setRawValue:[NSNumber numberWithDouble:42.0]]; // QCVirtualPort requires -setRawValue:
	[self setInputValue:[NSNumber numberWithBool:YES] forPort:@"inputPushing" onPatch:p];
	[self executePatch:p];
	GHAssertEquals([[[p valueForKey:@"outputStructure"] structureValue] count],(NSUInteger)1,@"structure should have one element");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:0],[NSNumber numberWithDouble:42.0],@"zeroth member of structure should be our number");


	// feed the structure back into the patch
	[[p valueForKey:@"inputStructure"] setStructureValue:[[p valueForKey:@"outputStructure"] structureValue]];

	// add something to the beginning
	[[p valueForKey:@"inputValue"] setRawValue:[NSNumber numberWithDouble:22.0]]; // QCVirtualPort requires -setRawValue:
	[self executePatch:p];
	GHAssertEquals([[[p valueForKey:@"outputStructure"] structureValue] count],(NSUInteger)2,@"structure should have two elements");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:0],[NSNumber numberWithDouble:22.0],@"zeroth member of structure should be the later number");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:1],[NSNumber numberWithDouble:42.0],@"first member of structure should be the original number");


	// feed the structure back into the patch
	[[p valueForKey:@"inputStructure"] setStructureValue:[[p valueForKey:@"outputStructure"] structureValue]];

	// add something to the end
	[self setInputValue:[NSNumber numberWithInteger:1] forPort:@"inputDirection" onPatch:p];
	[[p valueForKey:@"inputValue"] setRawValue:[NSNumber numberWithDouble:127.0]]; // QCVirtualPort requires -setRawValue:
	[self executePatch:p];
	GHAssertEquals([[[p valueForKey:@"outputStructure"] structureValue] count],(NSUInteger)3,@"structure should have three elements");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:0],[NSNumber numberWithDouble:22.0],@"zeroth member of structure should be the later number");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:1],[NSNumber numberWithDouble:42.0],@"first member of structure should be the original number");
	GHAssertEqualObjects([[[p valueForKey:@"outputStructure"] structureValue] memberAtIndex:2],[NSNumber numberWithDouble:127.0],@"first member of structure should be the latest number");

	[p release];
}

@end
