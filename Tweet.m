//
//  Tweet.m
//  iCodeOauth
//
//  Created by Collin Ruffenach on 9/14/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet

-(id)initWithTweetDictionary:(NSDictionary*)_contents {

	if(self = [super init]) {
	
		contents = _contents;
		[contents retain];
	}
	
	return self;
}

-(NSString*)tweet {

	return [contents objectForKey:@"text"];
}

-(NSString*)author {
	
	return [[contents objectForKey:@"user"] objectForKey:@"screen_name"];
}

@end
