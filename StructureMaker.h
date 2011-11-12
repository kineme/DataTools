@interface StructureMaker : QCPatch
{
	QCBooleanPort	*inputSkipEmptyInputs;
	//QCBooleanPort	*skipEmptyInputs;

	QCStructurePort	*outputStructure;
	
	QCVirtualPort	**ports;	// input ports
	QCStringPort	**portNames;	// input port names, if named
	
	unsigned int _inputCount;
	BOOL		 _named;	// 0 = indexed, 1 = named
	BOOL		 _emptyExposed;	// show/hide the skip empty input port
}

- (id)initWithIdentifier:(id)fp8;

- (BOOL)execute:(QCOpenGLContext *)context time:(double)time arguments:(NSDictionary *)arguments;

- (BOOL)isNamed;
- (unsigned int)inputCount;
- (BOOL)emptyExposed;

- (void)addInput;
- (void)delInput;
@end