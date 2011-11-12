#import "SkankySDK-TestCase.h"
#include <objc/objc-auto.h>
#include <mach/task.h>
#include <malloc/malloc.h>


@implementation SkankySDK_TestCase

- (void) setInputValue:(id)value forPort:(NSString *)portKey onPatch:(QCPatch*)patch
{
	QCPort *port = [patch valueForKey:portKey];
	if (port == nil) 
	{
		GHFail(@"Failed at time %f to find input port \"%@\"", patchTime, portKey); 
		return; 
	}
	if ([port isMemberOfClass:[QCVirtualPort class]])
		[(QCVirtualPort *)port setRawValue:value];  // setValue does nothing
	else
		[port setValue:value];
	object_setInstanceVariable(port,"_updated",(void *)YES);
}

- (id) getOutputForPort:(NSString *)portKey onPatch:(QCPatch*)patch
{
	QCPort *port = [patch valueForKey:portKey];
	if (port == nil)
	{
		GHFail(@"Failed at time %f to find output port \"%@\"", patchTime, portKey); 
		return nil; 
	}
	if ([port isKindOfClass:[QCStructurePort class]])
		return [(QCStructurePort *)port structureValue];  // -value likes to crash
	else
		return [port value]; 
}

- (void) setUpClass
{
	context = [[QCOpenGLContext alloc] initWithOptions:nil contextAttributes:0]; 
}

- (void) tearDownClass
{
	[context release]; 
}

- (void) setUp
{
	patches = [NSMutableSet setWithCapacity:1]; 
	patchTime = 0; 
}

- (void) tearDown
{
	for (QCPatch *patch in patches) 
	{
		[patch disable:context]; 
		[patch cleanup:context]; 
	}
	[patches removeAllObjects]; 
}

- (void) registerPatch:(QCPatch*)patch
{
	[patches addObject:patch]; 
	[patch setup:context]; 
	[patch enable:context]; 
	[self updateEachPortForPatch:patch]; 
}

- (void) executePatch:(QCPatch*)patch
{
	if (! [patches containsObject:patch])
		[self registerPatch:patch]; 
	BOOL success = [patch execute:context time:patchTime arguments:nil]; 
	[self unUpdateEachPortForPatch:patch]; 
	if (! success) 
	{
		NSMutableString *msg = [[NSMutableString alloc] initWithFormat:@"Failed at time %f to execute patch %@...", patchTime, patch]; 
		for (NSUInteger i = 0; i < [patch getNumberOfInputPorts]; i++) 
		{
			QCPort* port = [patch getNthInputPort:i]; 
			[msg appendFormat:@"%@=%@", [port key], [port value]]; 
			[msg replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [msg length])]; 
			if (i < [patch getNumberOfInputPorts] - 1)
				[msg appendFormat:@"..."]; 
		}
		GHFail(@"%@", msg); 
		[msg release]; 
	}
}

-(double)getTime
{
	return patchTime; 
}

- (void) setTime:(double)time
{
	patchTime = time; 
}

// If your composition uses any QC patches that don't support garbage collection (e.g. Structure Tools), 
// you must set Target UnitTests -> Build -> Objective-C Garbage Collection to Unsupported. Otherwise 
// "GC capability mismatch" errors show up in the console and the composition won't load properly. 
- (QCRenderer*) compositionWithFile:(NSString*)path
{
	QCRenderer *r = [[QCRenderer alloc] initWithComposition:[QCComposition compositionWithFile:path] colorSpace:CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear)];
	GHAssertNotNil(r, @"Failed to load composition from file \"%@\"", path);
	BOOL success = [r renderAtTime:patchTime arguments:nil]; 
	GHAssertTrue(success, @"Failed at time %f to render composition from file \"%@\"", patchTime, path); 
	[r autorelease]; 
	return r; 
}

// When a composition is opened from a file, wasUpdated seems to be YES initially for all ports. 
- (void) updateEachPortForPatch:(QCPatch*)patch
{
	for (NSUInteger i = 0; i < [patch getNumberOfInputPorts]; i++) 
	{
		NSString* portKey = [[patch getNthInputPort:i] key];
		[self setInputValue:[self getOutputForPort:portKey onPatch:patch] forPort:portKey onPatch:patch]; 
	}
}

// When a patch's execute method is called, wasUpdated doesn't automatically get set to NO. 
-(void)unUpdateEachPortForPatch:(QCPatch*)patch
{
	for (NSUInteger i = 0; i < [patch getNumberOfInputPorts]; i++) 
	{
		NSString* portKey = [[patch getNthInputPort:i] key];
		object_setInstanceVariable([patch valueForKey:portKey],"_updated",(void *)NO);
	}
}


#pragma mark GHUnitTestMain.m 

//
// GHUnitTestMain.m
// GHUnit
//
// Created by Gabriel Handford on 2/22/09.
// Copyright 2009. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import <GHUnit/GHUnit.h>
#import <GHUnit/GHTestApp.h>

// Default exception handler
void exceptionHandler(NSException *exception) {
	NSLog(NSLocalizedString(@"%@\n%@", @""), [exception reason], GHUStackTraceFromException(exception));
}

int main(int argc, char *argv[]) {
	
	/*!
	 For debugging:
	 Go into the "Get Info" contextual menu of your (test) executable (inside the "Executables" group in the left panel of XCode).
	 Then go in the "Arguments" tab. You can add the following environment variables:
	 Default: Set to:
	 NSDebugEnabled NO "YES"
	 NSZombieEnabled NO "YES"
	 NSDeallocateZombies NO "YES"
	 NSHangOnUncaughtException NO "YES"
	 NSEnableAutoreleasePool YES "NO"
	 NSAutoreleaseFreedObjectCheckEnabled NO "YES"
	 NSAutoreleaseHighWaterMark 0 non-negative integer
	 NSAutoreleaseHighWaterResolution 0 non-negative integer
	 For info on these varaiables see NSDebug.h; http://theshadow.uw.hu/iPhoneSDKdoc/Foundation.framework/NSDebug.h.html
	 For malloc debugging see: http://developer.apple.com/mac/library/documentation/Performance/Conceptual/ManagingMemory/Articles/MallocDebug.html
	 */
	
	NSSetUncaughtExceptionHandler(&exceptionHandler);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Register any special test case classes
	//[[GHTesting sharedInstance] registerClassName:@"GHSpecialTestCase"];
	
	int retVal = 0;
	// If GHUNIT_CLI is set we are using the command line interface and run the tests
	// Otherwise load the GUI app
	if (getenv("GHUNIT_CLI")) {
		retVal = [GHTestRunner run];
	} else {
		// To run all tests (from ENV)
		GHTestApp *app = [[GHTestApp alloc] init];
		// To run a different test suite:
		//GHTestSuite *suite = [GHTestSuite suiteWithTestFilter:@"GHSlowTest,GHAsyncTestCaseTest"];
		//GHTestApp *app = [[GHTestApp alloc] initWithSuite:suite];
		// Or set global:
		//GHUnitTest = @"GHSlowTest";
		[NSApp run];
		[app release];
	}
	[pool drain];
	return retVal;
}

