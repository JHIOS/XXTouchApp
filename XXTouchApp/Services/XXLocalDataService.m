//
//  XXLocalDataService.m
//  XXTouchApp
//
//  Created by Zheng on 8/30/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDefines.h"
#import "XXLocalDataService.h"
#import "JTSImageViewController.h"
#import "FYPhotoLibrary.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ALAssetsLibrary+SingleInstance.h"
#import "PHPhotoLibrary+CustomPhotoCollection.h"

static NSString * const kXXStorageAlbumName = @"XXTouch";

static NSString * const kXXTouchStorageDB = @"kXXTouchStorageDB-1";
static NSString * const kXXStorageKeyApplicationBundles = @"kXXStorageKeyApplicationBundles-1";
static NSString * const kXXStorageKeyStartUpConfigScriptPath = @"kXXStorageKeyStartUpConfigScriptPath-1";
static NSString * const kXXStorageKeyRemoteAccessStatus = @"kXXStorageKeyRemoteAccessStatus-1";
static NSString * const kXXStorageKeyDeviceInfo = @"kXXStorageKeyDeviceInfo-%@";
static NSString * const kXXStorageKeyUserConfig = @"kXXStorageKeyUserConfig-1";
static NSString * const kXXStorageKeyExpirationDate = @"kXXStorageKeyExpirationDate-1";
static NSString * const kXXStorageKeyNowDate = @"kXXStorageKeyNowDate-1";
static NSString * const kXXStorageKeySortMethod = @"kXXStorageKeySortMethod-1";
static NSString * const kXXStorageKeyStartUpConfigSwitch = @"kXXStorageKeyStartUpConfigSwitch-1";
static NSString * const kXXStorageKeyActivatorInstalled = @"kXXStorageKeyActivatorInstalled-1";
static NSString * const kXXStorageKeyRecordConfigRecordVolumeUp = @"kXXStorageKeyRecordConfigRecordVolumeUp-1";
static NSString * const kXXStorageKeyRecordConfigRecordVolumeDown = @"kXXStorageKeyRecordConfigRecordVolumeDown-1";
static NSString * const kXXStorageKeyPressConfigHoldVolumeUp = @"kXXStorageKeyPressConfigHoldVolumeUp-1";
static NSString * const kXXStorageKeyPressConfigHoldVolumeDown = @"kXXStorageKeyPressConfigHoldVolumeDown-1";
static NSString * const kXXStorageKeyPressConfigPressVolumeUp = @"kXXStorageKeyPressConfigPressVolumeUp-1";
static NSString * const kXXStorageKeyPressConfigPressVolumeDown = @"kXXStorageKeyPressConfigPressVolumeDown-1";

@interface XXLocalDataService () <
    JTSImageViewControllerInteractionsDelegate
>
@property (nonatomic, strong) NSArray <NSString *> *randStrings;

@end

@implementation XXLocalDataService

+ (id)sharedInstance {
    static XXLocalDataService *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithName:kXXTouchStorageDB];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // Init Local Data Configure
        
    }
    return self;
}

- (NSString *)rootPath {
    if (!_rootPath) {
        if ([[NSFileManager defaultManager] isReadableFileAtPath:FEVER_PATH]) {
            _rootPath = FEVER_PATH;
        } else {
            _rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }
    }
    return _rootPath;
}

- (NSDateFormatter *)defaultDateFormatter {
    if (!_defaultDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _defaultDateFormatter = dateFormatter;
    }
    return _defaultDateFormatter;
}

- (NSDateFormatter *)shortDateFormatter {
    if (!_shortDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d/M/yy, h:mm a"];
        _shortDateFormatter = dateFormatter;
    }
    return _shortDateFormatter;
}

- (NSDateFormatter *)miniDateFormatter {
    if (!_miniDateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d/M/yy"];
        _miniDateFormatter = dateFormatter;
    }
    return _miniDateFormatter;
}

- (NSMutableArray <NSString *> *)pasteboardArr {
    if (!_pasteboardArr) {
        _pasteboardArr = [[NSMutableArray alloc] init];
    }
    return _pasteboardArr;
}

- (NSString *)startUpConfigScriptPath {
    return (NSString *)[self objectForKey:kXXStorageKeyStartUpConfigScriptPath];
}

- (void)setStartUpConfigScriptPath:(NSString *)startUpConfigScriptPath {
    [self setObject:startUpConfigScriptPath forKey:kXXStorageKeyStartUpConfigScriptPath];
}

- (BOOL)isSelectedScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [self.selectedScript hasPrefix:path];
}

- (BOOL)isSelectedStartUpScriptInPath:(NSString *)path {
    if (![path hasSuffix:@"/"]) {
        path = [path stringByAppendingString:@"/"];
    }
    return [self.startUpConfigScriptPath hasPrefix:path];
}

- (NSString *)remoteAccessURL {
    NSString *wifiAddress = [[UIDevice currentDevice] ipAddressWIFI];
    if (wifiAddress == nil) {
        return nil;
    }
    return [NSString stringWithFormat:remoteAccessUrl(), wifiAddress];
}

- (BOOL)remoteAccessStatus {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyRemoteAccessStatus] boolValue];
}

- (void)setRemoteAccessStatus:(BOOL)remoteAccessStatus {
    [self setObject:[NSNumber numberWithBool:remoteAccessStatus] forKey:kXXStorageKeyRemoteAccessStatus];
}

- (NSDictionary *)deviceInfo {
    return (NSDictionary *)[self objectForKey:[NSString stringWithFormat:kXXStorageKeyDeviceInfo, VERSION_BUILD]];
}

- (void)setDeviceInfo:(NSDictionary *)deviceInfo {
    [self setObject:deviceInfo forKey:[NSString stringWithFormat:kXXStorageKeyDeviceInfo, VERSION_BUILD]];
}

- (NSDictionary *)userConfig {
    return (NSDictionary *)[self objectForKey:kXXStorageKeyUserConfig];
}

- (void)setUserConfig:(NSDictionary *)userConfig {
    [self setObject:userConfig forKey:kXXStorageKeyUserConfig];
}

- (NSDate *)nowDate {
    return (NSDate *)[self objectForKey:kXXStorageKeyNowDate];
}

- (void)setNowDate:(NSDate *)nowDate {
    [self setObject:nowDate forKey:kXXStorageKeyNowDate];
}

- (NSDate *)expirationDate {
    return (NSDate *)[self objectForKey:kXXStorageKeyExpirationDate];
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    [self setObject:expirationDate forKey:kXXStorageKeyExpirationDate];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    imageViewer.view.userInteractionEnabled = NO;
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // 7.x
        [[ALAssetsLibrary sharedLibrary] saveImage:imageViewer.image
                                           toAlbum:kXXStorageAlbumName
                                        completion:^(NSURL *assetURL, NSError *error) {
                                            if (error == nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:NSLocalizedString(@"Image saved to the album", nil)];
                                                });
                                            }
                                        } failure:^(NSError *error) {
                                            if (error != nil) {
                                                dispatch_async_on_main_queue(^{
                                                    imageViewer.view.userInteractionEnabled = YES;
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:[error localizedDescription]];
                                                });
                                            }
                                        }];
    } else {
        // 8.0+
        [[FYPhotoLibrary sharedInstance] requestLibraryAccessHandler:^(FYPhotoLibraryPermissionStatus statusResult) {
            if (statusResult == FYPhotoLibraryPermissionStatusDenied) {
                imageViewer.view.userInteractionEnabled = YES;
                [imageViewer.view hideToastActivity];
                [imageViewer.view makeToast:NSLocalizedString(@"Failed to request photo library access", nil)];
            } else if (statusResult == FYPhotoLibraryPermissionStatusGranted) {
                [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                                       toAlbum:kXXStorageAlbumName
                                                    completion:^(BOOL success) {
                                                        if (success) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:NSLocalizedString(@"Image saved to the album", nil)];
                                                            });
                                                        }
                                                    } failure:^(NSError * _Nullable error) {
                                                        if (error != nil) {
                                                            dispatch_async_on_main_queue(^{
                                                                imageViewer.view.userInteractionEnabled = YES;
                                                                [imageViewer.view hideToastActivity];
                                                                [imageViewer.view makeToast:[error localizedDescription]];
                                                            });
                                                        }
                                                    }];
            }
        }];
    }
}

- (kXXScriptListSortMethod)sortMethod {
    return [(NSNumber *)[self objectForKey:kXXStorageKeySortMethod] integerValue];
}

- (void)setSortMethod:(kXXScriptListSortMethod)sortMethod {
    [self setObject:[NSNumber numberWithInteger:sortMethod] forKey:kXXStorageKeySortMethod];
}

- (BOOL)startUpConfigSwitch {
    return [(NSNumber *)[self objectForKey:kXXStartUpConfigSwitch] boolValue];
}

- (void)setStartUpConfigSwitch:(BOOL)startUpConfigSwitch {
    [self setObject:[NSNumber numberWithBool:startUpConfigSwitch] forKey:kXXStartUpConfigSwitch];
}

- (BOOL)keyPressConfigActivatorInstalled {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyActivatorInstalled] boolValue];
}

- (void)setKeyPressConfigActivatorInstalled:(BOOL)keyPressConfigActivatorInstalled {
    [self setObject:[NSNumber numberWithBool:keyPressConfigActivatorInstalled] forKey:kXXStorageKeyActivatorInstalled];
}

- (BOOL)recordConfigRecordVolumeUp {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyRecordConfigRecordVolumeUp] boolValue];
}

- (void)setRecordConfigRecordVolumeUp:(BOOL)recordConfigRecordVolumeUp {
    [self setObject:[NSNumber numberWithBool:recordConfigRecordVolumeUp] forKey:kXXStorageKeyRecordConfigRecordVolumeUp];
}

- (BOOL)recordConfigRecordVolumeDown {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyRecordConfigRecordVolumeDown] boolValue];
}

- (void)setRecordConfigRecordVolumeDown:(BOOL)recordConfigRecordVolumeDown {
    [self setObject:[NSNumber numberWithBool:recordConfigRecordVolumeDown] forKey:kXXStorageKeyRecordConfigRecordVolumeDown];
}

- (kXXKeyPressConfig)keyPressConfigHoldVolumeUp {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyPressConfigHoldVolumeUp] integerValue];
}

- (void)setKeyPressConfigHoldVolumeUp:(kXXKeyPressConfig)keyPressConfigHoldVolumeUp {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigHoldVolumeUp] forKey:kXXStorageKeyPressConfigHoldVolumeUp];
}

- (kXXKeyPressConfig)keyPressConfigHoldVolumeDown {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyPressConfigHoldVolumeDown] integerValue];
}

- (void)setKeyPressConfigHoldVolumeDown:(kXXKeyPressConfig)keyPressConfigHoldVolumeDown {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigHoldVolumeDown] forKey:kXXStorageKeyPressConfigHoldVolumeDown];
}

- (kXXKeyPressConfig)keyPressConfigPressVolumeUp {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyPressConfigPressVolumeUp] integerValue];
}

- (void)setKeyPressConfigPressVolumeUp:(kXXKeyPressConfig)keyPressConfigPressVolumeUp {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigPressVolumeUp] forKey:kXXStorageKeyPressConfigPressVolumeUp];
}

- (kXXKeyPressConfig)keyPressConfigPressVolumeDown {
    return [(NSNumber *)[self objectForKey:kXXStorageKeyPressConfigPressVolumeDown] integerValue];
}

- (void)setKeyPressConfigPressVolumeDown:(kXXKeyPressConfig)keyPressConfigPressVolumeDown {
    [self setObject:[NSNumber numberWithInteger:keyPressConfigPressVolumeDown] forKey:kXXStorageKeyPressConfigPressVolumeDown];
}

- (NSArray <NSString *> *)randStrings {
    if (!_randStrings) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"extendHisLife" ofType:@"plist"];
        NSArray *arr = [[NSArray alloc] initWithContentsOfFile:plistPath];
        if (arr) {
            _randStrings = arr;
        } else {
            _randStrings = @[];
        }
    }
    return _randStrings;
}

- (NSString *)randString {
    NSUInteger rand = arc4random() % self.randStrings.count;
    return self.randStrings[rand];
}

- (NSArray *)bundles {
    NSArray *bundles = (NSArray *)[self objectForKey:kXXStorageKeyApplicationBundles];
    if (!bundles)
        return @[];
    return bundles;
}

- (void)setBundles:(NSArray *)bundles {
    [self setObject:bundles forKey:kXXStorageKeyApplicationBundles];
}

@end
