//
//  DbModelMeta.h
//  FMDBORM
//
//  Created by Muthu Rama on 18/04/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface DBModelMeta : NSObject

-(void)modelAddByType:(Class)modelType;

-(void)modelAddByName:(NSString*)modelName;

-(NSString*)modelGetName;

-(NSString*)modelGetTableName;

-(NSString*)modelGetPrimaryKeyName;

-(int)propertyCount;

-(BOOL)propertySetCurrentByIndex:(int)index;

-(BOOL)propertyGetIsKey;

-(BOOL)propertySetCurrentByName:(NSString*)propertyName;
-(void)propertySetIsKey:(BOOL)isKey;


-(BOOL)propertyGetIsReadOnly;

-(BOOL)propertyGetIgnore;

-(NSString*)propertyGetColumnName;

-(NSString*)propertyGetName;

-(NSString*)propertyGetType;

-(void)merge:(DBModelMeta*)modelMeta;

-(BOOL)modelSetCurrentByIndex:(int)index;

@end
