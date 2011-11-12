@interface DTSampleHoldPatch : QCPatch
{
	QCVirtualPort *inputValue;
	QCBooleanPort *inputSampling;

	QCVirtualPort *outputValue;

	id priorValue;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(BOOL)setup:(QCOpenGLContext*)context;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end

bool DTIsValueSerializable(id v);
