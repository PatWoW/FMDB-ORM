//
//  DbModelMeta.m
//  FMDBORM
//
//  Created by Muthu Rama on 18/04/2014.
//  Copyright (c) 2014 Black Pearl Info Tech. All rights reserved.
//

#import "DBModelMeta.h"

@interface DBModelMeta()

@property(strong,nonatomic) NSMutableArray* meta;
@property(strong,nonatomic) NSMutableDictionary* currentModel;
@property(strong,nonatomic) NSMutableDictionary* currentProperty;

@end

@implementation DBModelMeta



-(void)modelAddByType:(Class)modelType {
    
    NSString* modelName =[NSString stringWithCString:class_getName(modelType)
                                            encoding:NSUTF8StringEncoding];
    
    [self modelAddByName:modelName];
    
    
    [self addPropertiesForClass:modelType];
    
    
}


-(void)modelAddByName:(NSString*)modelName {
    NSMutableDictionary* model = [self findModel:modelName];
    if(model==nil){
        model = [NSMutableDictionary dictionary];
        [model setObject:modelName forKey:@"name"];
        [model setObject:modelName forKey:@"tableName"];
        [model setObject:[NSMutableArray array] forKey:@"properties"];
        [self.meta addObject:model];
    }
    self.currentModel = model;
}


-(NSString*)modelGetPrimaryKeyName{
    int propertyCount  = [self propertyCount];
    for(int propertyIndex = 0; propertyIndex<propertyCount;propertyIndex++){
        [self propertySetCurrentByIndex:propertyIndex];
        if([self propertyGetIsKey]){
            return [self propertyGetName];
        }
    }
    return nil;
}

-(void)addPropertiesForClass:(Class)clazz{
    unsigned int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    
    for (int i = 0; i < count ; i++){
        const char* propertyName = property_getName(properties[i]);
        
        NSString* propName =[NSString  stringWithCString:propertyName
                                                encoding:NSUTF8StringEncoding];
        
        
        NSMutableDictionary* property = [self findProperty:propName];
        if(property==nil){
            property = [self addProperty:propName];
            self.currentProperty = property;
            [self setupNewClassProperty:propName i:i properties:properties];
        }
        else{
            self.currentProperty = property;
        }
    }
    free(properties);
}

-(void)merge:(DBModelMeta*)modelMeta{
    
    int modelsCount = [modelMeta modelCount];
    for(int modelIndex = 0; modelIndex<modelsCount;modelIndex++){
        
        [modelMeta modelSetCurrentByIndex:modelIndex];
        NSMutableDictionary*localModel = [self findModel:[modelMeta modelGetName]];
        
        if(localModel){
            int propertyCount  = [modelMeta propertyCount];
            for(int propertyIndex = 0; propertyIndex<propertyCount;propertyIndex++){
                
                [modelMeta propertySetCurrentByIndex:propertyIndex];
                
                if([self findProperty:[modelMeta propertyGetName]] == false){
                    NSMutableDictionary* property = [modelMeta performSelector:@selector(findProperty:)
                                                                    withObject:[modelMeta propertyGetName]];
                    [[localModel objectForKey:@"properties"]addObject:property];
                }
            }
        }
        else{
            NSMutableDictionary* model = [modelMeta performSelector:@selector(findModel:)
                                                         withObject:[modelMeta modelGetName]];
            [self.meta addObject:model];
        }
    }
}


-(int)modelCount{
    return (int)[self.meta count];
}

-(NSString*)modelGetName{
    return[self.currentModel objectForKey:@"name"];
}
-(BOOL)modelSetCurrentByIndex:(int)index{
    if(index >= [self modelCount]) return false;
    self.currentModel = [self.meta objectAtIndex:index];
    return true;
}

-(NSMutableDictionary*)findModel:(NSString*)name{
    for(NSMutableDictionary* dic in self.meta){
        if([[dic objectForKey:@"name"]isEqualToString:name]){
            return dic;
        }
    }
    return nil;
}

-(BOOL)propertySetCurrentByName:(NSString*)propertyName{
    self.currentProperty = [self findProperty:propertyName];
    return self.currentProperty != nil;
}

-(NSMutableDictionary*)addProperty:(NSString*)propertyName{
    NSMutableDictionary* property = [NSMutableDictionary dictionary];
    [property setObject:propertyName forKey:@"name"];
    [property setObject:propertyName forKey:@"columnName"];
    [[self.currentModel objectForKey:@"properties"]addObject:property];
    return property;
}

-(NSMutableDictionary*)findProperty:(NSString*)name{
    NSArray* properties = [self.currentModel objectForKey:@"properties"];
    for(NSMutableDictionary* property in properties){
        if([[property objectForKey:@"name"]isEqualToString:name]){
            return property;
        }
    }
    return nil;
}

- (void)setupNewClassProperty:(NSString *)propName i:(int)i properties:(objc_property_t *)properties {
    
    if([propName caseInsensitiveCompare:
        [NSString stringWithFormat:@"id"]]==NSOrderedSame){
        [self propertySetIsKey:true];
    }
    [self propertySetType:[self property_getTypeString:properties[i]]];
}


-(NSString*) property_getTypeString:( objc_property_t) property {
    
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
    
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
    
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
    
	return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

-(void)propertySetType:(NSString*)typeName{
    [self.currentProperty setObject:typeName forKey:@"propertyType"];
}

-(NSString*)modelGetTableName{
    
    NSString *tblName = [self.currentModel objectForKey:@"tableName"];
    NSString *strip2Letter = [tblName substringWithRange:NSMakeRange(2, [tblName length]-2)];
    
    return strip2Letter;
}

-(int)propertyCount{
    return (int)[[self.currentModel objectForKey:@"properties"] count];
}

-(BOOL)propertySetCurrentByIndex:(int)index{
    if(index >= [self propertyCount]) return false;
    self.currentProperty = [[self.currentModel objectForKey:@"properties"]objectAtIndex:index];
    return true;
}

-(BOOL)propertyGetIsKey{
    return [[self.currentProperty objectForKey:@"isKey"]boolValue];
}


-(NSString*)propertyGetName{
    return [self.currentProperty objectForKey:@"name"];
}

-(void)propertySetIsKey:(BOOL)isKey{
    [self clearPrimaryKey];
    [self.currentProperty setObject:[NSNumber numberWithBool:isKey] forKey:@"isKey"];
}

-(NSString*)clearPrimaryKey{
    for(NSMutableDictionary *property in [self.currentModel objectForKey:@"properties"]){
        [property setObject:[NSNumber numberWithBool:false] forKey:@"isKey"];
    }
    return nil;
}


-(BOOL)propertyGetIsReadOnly{
    return [[self.currentProperty objectForKey:@"isReadOnly"]boolValue];
}

-(BOOL)propertyGetIgnore{
    return [[self.currentProperty objectForKey:@"ignore"]boolValue];
}


-(NSString*)propertyGetColumnName{
    return [self.currentProperty objectForKey:@"columnName"];
}

-(NSString*)propertyGetType{
    return [self.currentProperty objectForKey:@"propertyType"];
}
@end
