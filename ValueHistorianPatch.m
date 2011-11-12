#import "ValueHistorianPatch.h"
#import "ValueHistorianPatchUI.h"

#import "DTSampleHoldPatch.h"

static int indexForTimestamp(NSArray *timeStamps, double time)
{
	// if there's only one entry, use it
	if([timeStamps count] == 1)
		return 0;

	// if time's past the end of the array, use the last entry
	if(time > [[timeStamps lastObject] doubleValue])
		return [timeStamps count] - 1;

	// binary search to time point
	int first = 0, mid = -1, last = [timeStamps count];
	
	while(first < last)
	{
		mid = (first+last+1) / 2;
		double val = [[timeStamps objectAtIndex: mid] doubleValue];
		if(time < val)
			last = mid - 1;
		else if(time > val)
			first = mid;
		else
			return mid;	// lucky us, we found it
	}
	return first;
}

@implementation ValueHistorianPatch : QCPatch

+ (BOOL)allowsSubpatchesWithIdentifier:(id)fp8
{
	return NO;
}

+ (QCPatchTimeMode)timeModeWithIdentifier:(id)fp8
{
	return kQCPatchTimeModeTimeBase;
}

+ (Class)inspectorClassWithIdentifier:(id)fp8
{
	return [ValueHistorianPatchUI class];
}

- (id)initWithIdentifier:(id)fp8
{
	if(self=[super initWithIdentifier:fp8])
	{
		[[self userInfo] setObject:@"Kineme Value Historian" forKey:@"name"];

		[inputRecord setMaxIndexValue: 1];
		// hopefully preallocation will make the first recorded value not quite as expensive
		timeStamps = [[NSMutableArray alloc] initWithCapacity: 128];
		valueArray = [[NSMutableArray alloc] initWithCapacity: 128];

		// start out with one port, so users have a better idea what this patch does
		[self addPort];
	}

	return self;
}

-(void)dealloc
{
	[timeStamps release];
	[valueArray release];
	[super dealloc];
}

- (void)enable:(QCOpenGLContext *)context
{
	[outputDuration setDoubleValue: [[timeStamps lastObject] doubleValue]];
	[outputSamples setIndexValue: [timeStamps count]];
}
- (void)disable:(QCOpenGLContext *)context
{
	if(haveRecorded)
		[self stateUpdated];
}


- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments
{
	unsigned int i;
	
	if([inputReset booleanValue])
	{
		// ba-leted!
		[timeStamps removeAllObjects];
		[valueArray removeAllObjects];
		[outputSamples setIndexValue: 0];
		[outputDuration setDoubleValue: 0];
		[self stateUpdated];
		haveRecorded = NO;
		return YES;
	}
	
	// mark dirty if switching out of record mode (but composition is still running)
	if(haveRecorded && [inputRecord wasUpdated] && [inputRecord indexValue]==1)
		[self stateUpdated];

	if([inputRecord indexValue])	// playback mode
	{
		int idx = indexForTimestamp(timeStamps, time);
		if(idx == -1)	// empty array
			return YES;
		if(idx < [valueArray count])
		{
			NSArray *values = [valueArray objectAtIndex: idx];
			NSArray *outputs = [self customOutputPorts];
			for(i = 0; i < portCount; ++i)
				[[outputs objectAtIndex:i] setRawValue: [values objectAtIndex: i]];
		}
	}
	else	// record mode
	{
		BOOL updated = NO;
		haveRecorded = YES;
		NSArray *inputs = [self customInputPorts];
		NSArray *outputs = [self customOutputPorts];

		if(![inputRecord wasUpdated])
		{
			// if we're already in record mode and nothing has updated, don't bother snapshotting.
			// but if we're switching into record mode, snapshot everything.
			for(i = 0; i < portCount && !updated; ++i)
				updated |= [[inputs objectAtIndex:i] wasUpdated];
			if(!updated)
				return YES;
		}
		
		// reset the clock?  nuke the data after the current time:(
		// (in part, this helps keep our timestamp/valuedict arrays sorted)
		if(time < [[timeStamps lastObject] doubleValue])
		{
			int i;
			int idx = indexForTimestamp(timeStamps, time);
			for(i = idx; i < [timeStamps count]; ++i)
			{
				[timeStamps removeLastObject];
				[valueArray removeLastObject];
			}
		}
		
		// patch through values
		NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity: portCount];
		for(i = 0; i < portCount; ++i)
		{
			id value = [[inputs objectAtIndex:i] rawValue];
			[[outputs objectAtIndex:i] setRawValue: value];
			if(value)
				[values addObject: value];
			else
				[values addObject: [NSNumber numberWithInt: 0]];
		}
		// build/record dictionary data
		[timeStamps addObject: [NSNumber numberWithDouble: time]];
		[valueArray addObject: values];
		[values release];
		// This is impossibly expensive...
		//[self stateUpdated];	// mark document as changed (this might get annoying :)
		[outputDuration setDoubleValue: time];
	}

	[outputSamples setIndexValue: [timeStamps count]];
	
	return YES;
}

- (NSDictionary*)state
{
	NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] init];
	[stateDict autorelease];
	
	[stateDict addEntriesFromDictionary: [super state]];
	
	[stateDict setObject: [NSNumber numberWithUnsignedInt: portCount] forKey: @"VHPortCount"];

	NSArray *ports = [self customInputPorts];
	NSMutableArray *portNames = [[NSMutableArray alloc] initWithCapacity: [ports count]];
	unsigned int i;
	for(i = 0; i < [ports count]; ++i)
	{
		QCPort *port = [ports objectAtIndex: i];
		NSString *name = [[port attributes] objectForKey: @"name"];
		if(name)
			[portNames addObject: name];
		else
			[portNames addObject: @""];	// don't add nil!
	}
	
	[stateDict setObject: portNames forKey: @"VHPortNames"];
	[portNames release];


	// if the data isn't serializable, pop up a warning and don't try to save it
	for(id v in valueArray)
		if(!DTIsValueSerializable(v))
			return stateDict;

	[stateDict setObject: timeStamps forKey: @"VHTimes"];

	{
		// placing a QCImage, QCStructure, or some other stuff directly into stateDict causes a "Property list invalid for format" error, but archiving it and then placing NSData in there does seem to work.
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject:valueArray];
		[stateDict setObject:d forKey:@"VHValues"];
	}

	// VHVersion undefined = raw VHValues array in stateDict
	// VHVersion 2 = VHValues encoded using NSKeyedArchiver
	[stateDict setObject:[NSNumber numberWithInteger:2] forKey:@"VHVersion"];
	
	return stateDict;
}

- (BOOL)setState:(NSDictionary*)state
{
	while(portCount)
		[self removePort];

	unsigned int i, finalPortCount;
	finalPortCount = [[state objectForKey: @"VHPortCount"] unsignedIntValue];
	NSArray *portNames = [state objectForKey: @"VHPortNames"];
	
	for(i = 0; i < finalPortCount; ++i)
		[self addPortWithName: [portNames objectAtIndex: i]];
	
	[timeStamps addObjectsFromArray: [state objectForKey: @"VHTimes"]];
	
	if(![state objectForKey:@"VHVersion"])
		[valueArray addObjectsFromArray:[state objectForKey:@"VHValues"]];
	else
		[valueArray addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:[state objectForKey:@"VHValues"]]];

	return [super setState: state];
}

- (void)addPortWithName:(NSString*)name
{
	// can't insert nil into a dictionary, and empty names are dumb...
	name = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	// only use first line -- multi line names render on the following port if it exists...
	name = [[name componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] objectAtIndex: 0];
	if(name == nil || [name length] == 0)
	{
		[self addPort];
		return;
	}
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity: 2];
	[attributes setObject: name forKey: @"name"];
	[self createInputWithPortClass:[QCVirtualPort class] forKey: [NSString stringWithFormat:@"Input %i", portCount+1] attributes: attributes];
	[self createOutputWithPortClass:[QCVirtualPort class] forKey: [NSString stringWithFormat:@"Output %i", portCount+1] attributes: attributes];
	[attributes release];

	++portCount;	
}

- (void)addPort
{
	[self createInputWithPortClass:[QCVirtualPort class] forKey: [NSString stringWithFormat:@"Input %i", portCount+1] attributes: nil];
	[self createOutputWithPortClass:[QCVirtualPort class] forKey: [NSString stringWithFormat:@"Output %i", portCount+1] attributes: nil];

	++portCount;
	//portInputs = [self inputPorts];
	//portOutputs = [self outputPorts];
}

- (void)removePort
{
	if(portCount)
	{
		[self deleteInputForKey: [NSString stringWithFormat: @"Input %i", portCount]];
		[self deleteOutputForKey: [NSString stringWithFormat: @"Output %i", portCount]];
		[self stateUpdated];
		--portCount;
	}
}

- (void)exportData:(NSString*)filename
{
	// if the data isn't serializable, pop up a warning and don't try to save it
	for(id v in valueArray)
		if(!DTIsValueSerializable(v))
			return;

	NSString *error = nil;
	NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] initWithCapacity: 2];
	[saveDict setObject: timeStamps forKey: @"VHTimes"];
	{
		// placing a QCImage, QCStructure, or some other stuff directly into stateDict causes a "Property list invalid for format" error, but archiving it and then placing NSData in there does seem to work.
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject:valueArray];
		[saveDict setObject:d forKey:@"VHValues"];
	}
	[saveDict setObject:[NSNumber numberWithInteger:2] forKey:@"VHVersion"];

	[[NSPropertyListSerialization dataFromPropertyList: saveDict
												format: NSPropertyListBinaryFormat_v1_0 
									  errorDescription: &error] writeToFile: filename atomically: NO];
	if(error)
	{
		// shouldn't happen
//		NSLog(@"saveDict: %@", saveDict);
//		NSLog(@"error: %@", error);
		[error release];
	}
	[saveDict release];
}

- (void)importData:(NSString*)filename
{
	NSMutableDictionary *loadDict;

	[timeStamps removeAllObjects];
	[valueArray removeAllObjects];
	
	loadDict = 	[NSPropertyListSerialization propertyListFromData: [NSData dataWithContentsOfFile: filename]
												 mutabilityOption: NSPropertyListImmutable
														   format: NULL
												 errorDescription: nil];
	
	[timeStamps addObjectsFromArray: [loadDict objectForKey: @"VHTimes"]];
	if(![loadDict objectForKey:@"VHVersion"])
		[valueArray addObjectsFromArray:[loadDict objectForKey:@"VHValues"]];
	else
		[valueArray addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:[loadDict objectForKey:@"VHValues"]]];
	//NSLog(@"loaded %i timestamps and %i values", [timeStamps count], [valueArray count]);
}

@end
