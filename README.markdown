# Kineme DataTools

Kineme DataTools is a Quartz Composer plugin that provides patches for: 

   - Creating and manipulating structures (`Structure Break-Out`, `Structure Combine`, `Structure Equal`, `Structure Key`, `Structure Pop`, `Structure Push`, `Structure Maker`, `Named Structure Maker`)
   - Sending data between unconnected patches (`Spooky Send/Receive`)
   - Evaluating multiple math expressions in one patch (`Multi-Expression`)
   - Capturing and replaying values, and saving them into the composition (`Value Historian`)
   - Sampling values, and saving them into the composition (`Sample and Hold`)
   - Converting Quartz Composer data types to and from raw bytes (`Convert To Data`, `Convert From Data`)
   - Outputting a unique number for each instance of the patch (`Order`)

For more Quartz Composer plugins and compositions, plus community forums, go to [kineme.net](http://kineme.net). 

## How to get it

Download or clone it [from GitHub](https://github.com/kineme/DataTools). 

## How to install it

   1. Uninstall Kineme StructureTools, Kineme Value Historian, and Kineme Spooky if they are installed. 
   2. Install the [QCPatch Xcode Template](http://kineme.net/release/QCPatchXcodeTemplate/10), a.k.a. Quartz Composer unofficial API, a.k.a. SkankySDK. 
   3. Build DataTools.xcodeproj. This will create the file ~/Library/Graphics/Quartz Composer Patches/DataTools.plugin. 
   4. Restart Quartz Composer. The patches will show up under the Kineme DataTools category. 

## License

Kineme DataTools is released under the MIT License. 
