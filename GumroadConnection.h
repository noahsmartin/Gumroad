//
//  GumroadConnection.h
//  Gumroad
//
//  Created by Noah Martin on 12/12/13.
//  Copyright (c) 2013 Noah Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GumroadConnection : NSObject

@property (strong, nonatomic) NSString* token;

-(GumroadConnection*) initWithToken:(NSString*)token;

// All instance methdos will return null if no token is set

// returns a dictionary of keys that are NSString aplicaiton names and values that are NSString ids
-(NSDictionary*)applicationIds;

-(NSDictionary*)infoForApplicationId:(NSString*)appId;

@end
