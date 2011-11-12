#import <GHUnit/GHUnit.h>


@interface SkankySDK_TestCase : GHTestCase {
	NSMutableSet * patches; 
	double patchTime; 
	QCOpenGLContext *context;  
}

- (void) setInputValue:(id)value forPort:(NSString *)portKey onPatch:(QCPatch*)patch; 
- (id) getOutputForPort:(NSString *)portKey onPatch:(QCPatch*)patch; 
- (void) setUpClass;
- (void) setUp; 
- (void) tearDownClass; 
- (void) tearDown; 
- (void) executePatch:(QCPatch*)patch; 
- (double) getTime; 
- (void) setTime:(double)time; 
- (QCRenderer*) compositionWithFile:(NSString*)path; 
- (void) updateEachPortForPatch:(QCPatch*)patch;
- (void) unUpdateEachPortForPatch:(QCPatch*)patch; 

@end
