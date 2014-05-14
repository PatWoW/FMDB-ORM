//
//  PWStringUtils.m
//  FMDB-ORM
//
//  Created by Muthu Rama on 14/05/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import "PWStringUtils.h"

@implementation PWStringUtils

+(BOOL) isEqual:(NSString *) firstStr compareString:(NSString *) secondStr{
    
    if([self isEmpty:firstStr] || [self isEmpty:secondStr]){
        return NO;
        
    }
    return [[firstStr lowercaseString] isEqualToString:[secondStr lowercaseString]];
}


+(BOOL) isEqualString:(NSString *) firstStr compareString:(NSString *) secondStr{
    
    if([self isEmpty:firstStr] || [self isEmpty:secondStr]){
        return NO;
        
    }
    return [[firstStr lowercaseString] isEqualToString:[secondStr lowercaseString]];
}

+ (BOOL)isEmpty:(NSString*) string {
    
    // if ((urlString==nil) || (urlString == (NSString *)[NSNull null]) || ([urlString isEqualToString:@""]))
    
    if((string == nil) ||
       (string == (NSString *)[NSNull null]) ||
       ([string length] == 0) ||
       ([string isEqualToString:@""]) ||
       ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        
        return YES;
    }
    
    return NO;
}


+(NSArray *) sortDictionaryBasedOnKey:(NSDictionary *) dictionary Ascending:(BOOL) asc{
    
    NSArray *sortedValue = [[NSArray alloc]init];
    if (dictionary==nil) {
        return sortedValue;
    }
    
    NSArray *keysUpdated = [dictionary allKeys];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:asc];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *reverseOrderToSortValuesFromKeys1 = [keysUpdated sortedArrayUsingDescriptors:descriptors];
    sortedValue=[dictionary objectsForKeys:reverseOrderToSortValuesFromKeys1 notFoundMarker:[NSNull null]];
    return sortedValue;
    
}
@end
