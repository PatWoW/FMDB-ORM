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
/**
 *  <#Description#>
 *
 *  @param dataObject   <#dataObject description#>
 *  @param successBlock <#successBlock description#>
 *  @param failBlock    <#failBlock description#>
 *
 *	DBManger *dbMgr = [DBManager alloc]init];
 *  DBContact *contact = [DBContact alloc]init];
 
 * contact.fullName = @"Name of the person";
 
 * //contact.id = Auto generate id
 * //contact.createdOn - Auto stamped the date and time of the date created
 
 * [dbMgr insertRecord:contact
 * successBlock:^(NSNumber *pkId, NSString *msg) {
 
    //pkId - Primaey key id of the inserted record
 
    //Optional Msg = "New Contact created in the database"
 }
 failBlock:^(NSError *error, NSString *errMsg) {
 
 //if insert record fail then this blocks invokes with error id and error message
 
 }];
 */

-(void) insertRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  Description
 *
 *  @param dataObject   dataObject description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 *  DBManger *dbMgr = [DBManager alloc]init];
 *  DBContact *contact = [DBContact alloc]init];
 
 *  contact.fullName = @"Name of the person";
 *  contact.id = 2;
 
 *  [dbMgr updateRecord:contact
 *  successBlock:^(NSNumber *pkId, NSString *msg) {
 
 *  //pkid - updated record id
 *  //msg - Contact name updated
 *  }
 *   failBlock:^(NSError *error, NSString *errMsg) {
 *  //if update record fail then this blocks invokes with error id and error message
 *  }];
 */

-(void) updateRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  ### Delete Record
 *
 *  @param dataObject   dataObject description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 */
-(void) deleteRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  To check record exists
 *
 *  @param type         type description
 *  @param query        query description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 *
 *  @return return value description
 */
-(BOOL) isRecordExists:(Class)type Sql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  Delete record based on the sql with multiple where condition
 *
 *  @param query        query description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 */
-(void) deleteRecordSql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  Retrieve Record based on the primary Key
 *
 *  @param type         type description
 *  @param key          key description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 *
 *  @return return value description
 */
-(id) retrieveRecord:(Class)type key:(NSNumber *)key successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

/**
 *  Retrieve Multiple record set based on the sql
 *
 *  @param type         type description
 *  @param sql          sql description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 *
 *  @return return value description
 */
-(NSArray *) retrieveRecordSet:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;



/**
 *  Returns first record of the record set
 *
 *  @param type         type description
 *  @param sql          sql description
 *  @param successBlock successBlock description
 *  @param failBlock    failBlock description
 *
 *  @return return value description
 */
-(id ) retrieveFirstRecord:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;



@end
