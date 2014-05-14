//
//  PWStringUtils.h
//  FMDB-ORM
//
//  Created by Muthu Rama on 14/05/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PWStringUtils : NSObject


+(BOOL) isEqual:(NSString *) firstStr compareString:(NSString *) secondStr;

+(BOOL) isEqualString:(NSString *) firstStr compareString:(NSString *) secondStr;

+(BOOL) isEmpty:(NSString*) string;

+(NSArray *) sortDictionaryBasedOnKey:(NSDictionary *) dictionary Ascending:(BOOL) asc;


@end
