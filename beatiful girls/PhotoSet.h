//
//  PhotoSet.h
//  PhotoViewer
//
//  Created by Ray Wenderlich on 6/30/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface PhotoSet : TTURLRequestModel <TTPhotoSource> {
    NSString *_title;
    NSMutableArray *_photos;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSMutableArray *photos;

+ (PhotoSet *)samplePhotoSet;

@end

