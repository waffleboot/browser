
#import <Foundation/Foundation.h>

@interface NSURL (Browser)

@property (readonly) NSURL *canonicalURL;
@property (readonly) NSString *browserString;

+ (instancetype)URLWithBrowserString:(NSString *)string;

@end
