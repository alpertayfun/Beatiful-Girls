//
//  PhotoSet.m
//  PhotoViewer
//
//  Created by Ray Wenderlich on 6/30/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "PhotoSet.h"
#import "Photo.h"
#import "JSON.h"

@implementation PhotoSet

NSString const * resim_url = @"http://www.thatmailguy.com/bgirl/";
@synthesize title = _title;
@synthesize photos = _photos;

- (id) initWithTitle:(NSString *)title photos:(NSMutableArray *)photos {
    if ((self = [super init])) {
        self.title = title;
        self.photos = photos;
        for(int i = 0; i < _photos.count; ++i) {
            Photo *photo = [_photos objectAtIndex:i];
            photo.photoSource = self;
            photo.index = i;
        }        
    }
    return self;
}

- (void) dealloc {
    self.title = nil;
    self.photos = nil;    
    [super dealloc];
}

#pragma mark TTModel

- (BOOL)isLoading { 
    return FALSE;
}

- (BOOL)isLoaded {
    return TRUE;
}

#pragma mark TTPhotoSource

- (NSInteger)numberOfPhotos {
    return _photos.count;
}

- (NSInteger)maxPhotoIndex {
    return _photos.count-1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
        return [_photos objectAtIndex:photoIndex];
    } else {
        return nil;
    }
}

#pragma mark Singleton

static PhotoSet *samplePhotoSet = nil;

+ (PhotoSet *) samplePhotoSet {
    @synchronized(self) {
        if (samplePhotoSet == nil) {
            
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSString *urls = [NSString stringWithFormat:@"http://www.thatmailguy.com/bgirl/resims.htm"];
            NSLog(@"%@",urls);
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urls]];
            
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSMutableArray *photos = [NSMutableArray new];
            NSArray *statuses = [parser objectWithString:json_string error:nil];
            for (NSDictionary *status in statuses)
            {
                if ([[status objectForKey:@"type"] rangeOfString:@"RESIM"].location == NSNotFound) {
                    
                }else {
                    NSString *paths = [NSString stringWithFormat:@"%@%@.jpg",resim_url,[status objectForKey:@"name"]];
                    NSLog(@"%@",[status objectForKey:@"name"]);
                    Photo *photo = [[[Photo alloc] initWithCaption:[status objectForKey:@"key"]
                                                                  urlLarge:paths
                                                                  urlSmall:paths
                                                                  urlThumb:paths
                                                                      size:CGSizeMake(320, 480)] autorelease];
                    [photos addObject:photo];
                    
                }
            }
            [parser release];
            [pool release];

            samplePhotoSet = [[self alloc] initWithTitle:@"Beautiful Girls" photos:photos];

        }
    }
    return samplePhotoSet;
}

@end
