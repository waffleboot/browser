
#import <Foundation/Foundation.h>

@interface BrowserModel : NSObject
+ (instancetype)sharedModel;
- (NSString *)getHtmlByURL:(NSURL *)url;
- (void)saveHTML:(NSString *)html forURL:(NSURL *)url;
@end
