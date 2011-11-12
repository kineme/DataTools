@interface ValueHistorianPatch : QCPatch
{
	QCIndexPort		*inputRecord;	// record/playback
	QCBooleanPort	*inputReset;	// clears recorded data (permanently)
	
	QCIndexPort		*outputSamples;	// nuber of recorded timestamps
	QCNumberPort	*outputDuration;// length of recording
	
	NSMutableArray	*timeStamps;
	NSMutableArray	*valueArray;
	
	unsigned int portCount;
	
	//NSArray	*portInputs, *portOutputs;	// input/output port arrays
	BOOL	haveRecorded;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

- (NSDictionary*)state;
- (BOOL)setState:(NSDictionary*)state;

- (void)addPort;
- (void)addPortWithName:(NSString*)name;
- (void)removePort;

- (void)exportData:(NSString*)filename;
- (void)importData:(NSString*)filename;
@end