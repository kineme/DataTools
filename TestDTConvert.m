#import "SkankySDK/SkankySDK-TestCase.h"
#import "DTConvertToDataPatch.h"
#import "DTConvertFromDataPatch.h"
#import "DTStringToDataPatch.h"
#import "DTImageToDataPatch.h"
#import "DTDataCombinePatch.h"


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

- (void)testImageToData
{
	DTImageToDataPatch *patch = [[DTImageToDataPatch alloc] initWithIdentifier:nil];
	
	// TIFF image -> TIFF data
	NSImage *compressedTiffNSImage = [[NSImage alloc] initWithContentsOfFile:@"/Library/User Pictures/Fun/Pizza.tif"];
	NSData *inTiffData = [compressedTiffNSImage TIFFRepresentationUsingCompression:NSTIFFCompressionNone factor:0];
	NSImage *inTiffNSImage = [[NSImage alloc] initWithData:inTiffData];
	QCImage *inTiffQCImage = [[QCImage alloc] initWithNSImage:inTiffNSImage options:nil];
	[self setInputValue:inTiffQCImage forPort:@"inputImage" onPatch:patch];
	[self setInputValue:[NSNumber numberWithInt:NSTIFFFileType] forPort:@"inputImageFileType" onPatch:patch];
	[self executePatch:patch];
	NSData *outTiffData = [self getOutputForPort:@"outputRawData" onPatch:patch];
	const unsigned char expectedTiffBytes[] = { 0x4d, 0x4d, 0x00, 0x2a };
	NSData *expectedTiffData = [NSData dataWithBytes:(const void *)expectedTiffBytes length:4];
	GHAssertEqualObjects(expectedTiffData, [outTiffData subdataWithRange:NSMakeRange(0, 4)], @"");
//	NSBitmapImageRep *outTiffImageRep = [NSBitmapImageRep imageRepWithData:outTiffData];
//	GHAssertEqualObjects(inTiffData, [outTiffImageRep TIFFRepresentation], @"");
	[outTiffData writeToFile:@"/tmp/TestDTConvert_outTiff.tif" atomically:NO];
	
	// JPEG image -> PNG data
	QCImage *inJpegQCImage = [[QCImage alloc] initWithFile:@"/Library/Desktop Pictures/Solid Colors/Solid Aqua Blue.png" options:nil];
	[self setInputValue:inJpegQCImage forPort:@"inputImage" onPatch:patch];
	[self setInputValue:[NSNumber numberWithInt:NSPNGFileType] forPort:@"inputImageFileType" onPatch:patch];
	[self executePatch:patch];
	NSData *outPngData = [self getOutputForPort:@"outputRawData" onPatch:patch];
	const unsigned char expectedPngBytes[] = { 0x89, 0x50, 0x4e, 0x47 };
	NSData *expectedPngData = [NSData dataWithBytes:(const void *)expectedPngBytes length:4];
	GHAssertEqualObjects(expectedPngData, [outPngData subdataWithRange:NSMakeRange(0, 4)], @"");
	[outPngData writeToFile:@"/tmp/TestDTConvert_outPng.png" atomically:NO];
}

- (void)testDataCombine
{
	DTDataCombinePatch *patch = [[DTDataCombinePatch alloc] initWithIdentifier:nil];
	
	NSData *inData1 = [@"first" dataUsingEncoding:NSUTF8StringEncoding];
	NSData *inData2 = [@"second" dataUsingEncoding:NSUTF8StringEncoding];
	[self setInputValue:inData1 forPort:@"inputRawData1" onPatch:patch];
	[self setInputValue:inData2 forPort:@"inputRawData2" onPatch:patch];
	[self executePatch:patch];
	NSData *outData = [self getOutputForPort:@"outputRawData" onPatch:patch];
	NSString *outString = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
	GHAssertEqualStrings(@"firstsecond", outString, @"");
}

@end
