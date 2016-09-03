//
//  XXLocalCommandBaseRequest.h
//  XXTouchApp
//
//  Created by Zheng on 8/29/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXLocalDefines.h"
#import <Foundation/Foundation.h>

@interface XXLocalCommandBaseRequest : JSONModel
@property (nonatomic, assign) XXLocalCommandMethod requestMethod;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, copy) NSString *requestBody;

@end