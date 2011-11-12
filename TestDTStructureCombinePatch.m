#import "SkankySDK/SkankySDK-TestCase.h"

#import "DTStructureCombinePatch.h"
#import "DTStructureEqualPatch.h"


@interface TestDTStructureCombinePatch : SkankySDK_TestCase
@end

@implementation TestDTStructureCombinePatch

- (void)testStructureCombinePatch
{
	QCStructure *ar = [[QCStructure alloc] initWithArray:[NSArray arrayWithObjects:@"0",@"1",nil]];
	QCStructure *arar = [[QCStructure alloc] initWithArray:[NSArray arrayWithObjects:@"0",@"1",@"0",@"1",nil]];
	QCStructure *dict = [[QCStructure alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"a",@"a",@"b",@"b",nil]];

	DTStructureCombinePatch *p = [[DTStructureCombinePatch alloc] initWithIdentifier:nil];
	GHAssertNotNil(p,@"");

	// both nil
	[self executePatch:p];
	GHAssertEquals([[[p valueForKey:@"outputStructure"] structureValue] count],(NSUInteger)0,@"combination of two empty structures should be an empty structure");

	// second nil
	[[p valueForKey:@"inputStructure1"] setStructureValue:ar];
	[[p valueForKey:@"inputStructure2"] setStructureValue:nil];
	[self executePatch:p];
	GHAssertTrue(DTStructureCompare([[p valueForKey:@"outputStructure"] structureValue],ar),@"ar + nil should = ar");

	// first nil
	[[p valueForKey:@"inputStructure1"] setStructureValue:nil];
	[[p valueForKey:@"inputStructure2"] setStructureValue:dict];
	[self executePatch:p];
	GHAssertTrue(DTStructureCompare([[p valueForKey:@"outputStructure"] structureValue],dict),@"nil + dict should = dict");

	// ar + ar
	[[p valueForKey:@"inputStructure1"] setStructureValue:ar];
	[[p valueForKey:@"inputStructure2"] setStructureValue:ar];
	[self executePatch:p];
	GHAssertTrue(DTStructureCompare([[p valueForKey:@"outputStructure"] structureValue],arar),@"ar + ar should = arar");

	// dict + dict
	[[p valueForKey:@"inputStructure1"] setStructureValue:dict];
	[[p valueForKey:@"inputStructure2"] setStructureValue:dict];
	[self executePatch:p];
	GHAssertTrue(DTStructureCompare([[p valueForKey:@"outputStructure"] structureValue],dict),@"dict + dict should = dict");

	[p release];
	[dict release];
	[ar release];
}

@end
