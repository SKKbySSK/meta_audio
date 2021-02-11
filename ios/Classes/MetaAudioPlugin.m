#import "MetaAudioPlugin.h"
#if __has_include(<meta_audio/meta_audio-Swift.h>)
#import <meta_audio/meta_audio-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "meta_audio-Swift.h"
#endif

@implementation MetaAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMetaAudioPlugin registerWithRegistrar:registrar];
}
@end
