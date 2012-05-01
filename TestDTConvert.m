#import "SkankySDK/SkankySDK-TestCase.h"
#import "DTConvertToDataPatch.h"
#import "DTConvertFromDataPatch.h"
#import "DTStringToDataPatch.h"


@interface TestDTConvert : SkankySDK_TestCase
@end


@implementation TestDTConvert

- (void)testConvert
{
	DTConvertToDataPatch *toPatch = [[DTConvertToDataPatch alloc] initWithIdentifier:nil]; 
	DTConvertFromDataPatch *fromPatch = [[DTConvertFromDataPatch alloc] initWithIdentifier:nil]; 
	
	NSNumber *numberInput = [NSNumber numberWithDouble:3.14]; 
	[self setInputValue:numberInput forPort:@"inputObject" onPatch:toPatch]; 
	[self executePatch:toPatch]; 
	id numberData = [self getOutputForPort:@"outputRawData" onPatch:toPatch]; 
	[self setInputValue:numberData forPort:@"inputRawData" onPatch:fromPatch]; 
	[self executePatch:fromPatch]; 
	GHAssertEqualObjects(numberInput, [self getOutputForPort:@"outputObject" onPatch:fromPatch], @""); 
	
	NSDictionary *structureInput = [NSDictionary dictionaryWithObjectsAndKeys: @"a", @"1", @"j", @"10", nil]; 
	[self setInputValue:structureInput forPort:@"inputObject" onPatch:toPatch]; 
	[self executePatch:toPatch]; 
	id structureData = [self getOutputForPort:@"outputRawData" onPatch:toPatch]; 
	[self setInputValue:structureData forPort:@"inputRawData" onPatch:fromPatch]; 
	[self executePatch:fromPatch]; 
	GHAssertEqualObjects(structureInput, [self getOutputForPort:@"outputObject" onPatch:fromPatch], @""); 
	
	[self setInputValue:nil forPort:@"inputObject" onPatch:toPatch]; 
	[self executePatch:toPatch]; 
	GHAssertNil([self getOutputForPort:@"outputRawData" onPatch:toPatch], @""); 
	
	[self setInputValue:nil forPort:@"inputRawData" onPatch:fromPatch]; 
	[self executePatch:fromPatch]; 
	GHAssertNil([self getOutputForPort:@"outputObject" onPatch:fromPatch], @""); 
	
	[toPatch release]; 
	[fromPatch release]; 
}

- (void)testStringToData
{
	DTStringToDataPatch *patch = [[DTStringToDataPatch alloc] initWithIdentifier:nil];
	
	NSString *originalString = @"abc";
	[self setInputValue:originalString forPort:@"inputString" onPatch:patch];
	[self executePatch:patch];
	NSData *data = [self getOutputForPort:@"outputRawData" onPatch:patch];
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	GHAssertEqualStrings(originalString, dataString, @"");
	[dataString release];
}

@end
