
#import <Foundation/Foundation.h>

@protocol ViewModelDelegate;

@interface ViewModel : NSObject
- (instancetype)initWithDelegate:(id<ViewModelDelegate>)delegate;
- (void)openPageWithURL:(NSURL *)url;
- (void)savePageHTML:(NSString *)html withURL:(NSURL *)url;
- (void)reload:(NSURL *)url;
- (void)openRecentAddress;
- (NSString *)html:(NSURL *)url;
- (void)undo;
@end

@protocol ViewModelDelegate <NSObject>
- (void)openPageWithHTML:(NSString *)html baseURL:(NSURL *)baseUrl;
- (void)openPageWithURL:(NSURL *)url;
@end
