@interface ValueHistorianPatchUI : QCInspector
{
	IBOutlet NSTextField *portName;
}
- (IBAction)updatePortCount:(id)sender;
- (IBAction)saveData:(id)sender;
- (IBAction)loadData:(id)sender;
@end