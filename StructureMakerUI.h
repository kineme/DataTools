@interface StructureMakerUI : QCInspector
/* Inspector panel UI code goes here */
{
	IBOutlet NSStepper *stepper;
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *emptyInputButton;
}

- (IBAction)stepInputCount:(id)sender;
- (IBAction)textInputCount:(id)sender;
- (IBAction)emptyInputPort:(id)sender;
@end