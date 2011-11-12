#import "DTSpookyNexus.h"

@interface SpookySendPatch : QCPatch
{
    QCStringPort *inputSender;

    QCVirtualPort *inputObject;

	QCBooleanPort	*inputAutoClean;
	
	NSString *prevSender;
	__weak DTSpookyNexus *nexusManager;
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;
@end