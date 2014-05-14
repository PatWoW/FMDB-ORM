//
//  DBManager.h
//  ANZ_CLG
//
//  Created by Muthu Rama on 17/04/2014.
//  Copyright (c) 2014 PatWoW.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBObject.h"
#import "DBModelMeta.h"
#import "PWStringUtils.h"


@interface DBManager : NSObject


#define DB_NAME @"dbName.sqlite"

-(id)init;

-(id)initWithcreateEditableCopyOfDatabaseIfNeeded:(NSString*)name;

-(void) mergeModelMeta:(DBModelMeta *)meta;

typedef void (^DBSuccess)(NSNumber *pkId,NSString *msg);


typedef void (^DBFail)(NSError *error, NSString *errMsg);

@property (nonatomic, copy) DBSuccess dbSuccess;

/**
 * The callback block that will be called upon an error
 */
@property (nonatomic, copy) DBFail dbFail;

-(void) openDatabase;

/**
 *  closeing the database .
 */
-(void) closeDatabase;


/**
 
 *
 * completionBlock will be invoked if the database update was successfully
 * errorBlock will be invokedif there were any errors updating the request.
 *
 *
 * @param completionBlock The successful callback block
 * @param errorBlock The error callback block
 */

-(void) insertRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(void) updateRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;


-(void) deleteRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(BOOL) isRecordExists:(Class)type Sql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(void) deleteRecordSql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(id) retrieveRecord:(Class)type key:(NSNumber *)key successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(NSArray *) retrieveRecordSet:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

-(id ) retrieveFirstRecord:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;



@end
