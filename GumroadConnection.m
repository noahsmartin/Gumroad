//
//  GumroadConnection.m
//  Gumroad
//
//  Created by Noah Martin on 12/12/13.
//  Copyright (c) 2013 Noah Martin. All rights reserved.
//

#import "GumroadConnection.h"

@implementation GumroadConnection

-(GumroadConnection*) initWithToken:(NSString *)token
{
    if(self = [super init])
    {
        self.token = token;
    }
    return self;
}

-(NSDictionary*)applicationIds
{
    if(!self.token)
        return nil;
    NSString *urlAddress = [NSString stringWithFormat:@"https://api.gumroad.com/v2/products?access_token=%@", self.token];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    if(response)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
        NSMutableDictionary *ids = [[NSMutableDictionary alloc] init];
        NSArray* products = [result objectForKey:@"products"];
        for(NSDictionary* product in products)
        {
            [ids setObject:[product objectForKey:@"id"] forKey:[product objectForKey:@"name"]];
        }
        return ids;
    }
    return nil;
}

-(NSDictionary*)infoForApplicationId:(NSString *)appId
{
    if(!self.token)
        return nil;
    NSString *urlAddress = [NSString stringWithFormat:@"https://api.gumroad.com/v2/products/%@?access_token=%@", appId, self.token];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    if(response)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
        return [result objectForKey:@"product"];
    }
    return nil;
}

@end
