#import "DTSpookyNexus.h"
extern NSMutableDictionary *spookySenderObjects;

@interface SpookyReceivePatch : QCPatch
{
	QCStringPort *inputSender;
	
    QCVirtualPort *outputOutput;
	
//	// since we change our max constantly, state restoration gets obliterated at startup.  target works around that.
//	unsigned int targetIndex;
	
	__weak DTSpookyNexus *nexusManager;
}

- (id)initWithIdentifier:(id)fp8;

//- (BOOL)setup:(QCOpenGLContext *)context;
//- (void)cleanup:(QCOpenGLContext *)context;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

@end