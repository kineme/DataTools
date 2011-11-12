#import "DTOrderManager.h"

@interface DTOrderPatch : QCPatch
{
	QCStringPort *inputChannel;

	QCIndexPort *outputOrder;

	DTOrderManager *om;
}

+(BOOL)isSafe;
+(BOOL)allowsSubpatchesWithIdentifier:(id)identifier;
+(QCPatchExecutionMode)executionModeWithIdentifier:(id)identifier;
+(QCPatchTimeMode)timeModeWithIdentifier:(id)identifier;
-(id)initWithIdentifier:(id)identifier;
-(void)enable:(QCOpenGLContext*)context;
-(void)disable:(QCOpenGLContext*)context;
-(BOOL)execute:(QCOpenGLContext*)context time:(double)time arguments:(NSDictionary*)arguments;

@end
