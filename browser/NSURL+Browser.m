
#import "NSURL+Browser.h"

@implementation NSURL (Browser)

+ (instancetype)URLWithBrowserString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithDataRepresentation:stringData relativeToURL:nil];
}

- (NSString *)browserString {
    return self.relativeString.stringByRemovingPercentEncoding;
}

- (NSURL *)canonicalURL {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = self.scheme;
    components.host = self.host;
    components.port = self.port;
    components.path = self.path;
    return components.URL;
}

@end
