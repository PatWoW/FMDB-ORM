//
//  DBManager.m
//  ANZ_CLG
//
//  Created by Muthu Rama on 17/04/2014.
//  Copyright (c) 2014 PatWoW.com. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"
#import "DBModelMeta.h"

@interface DBManager () {
  
}

@property (strong, nonatomic) DBModelMeta* modelMeta;

@end

@implementation DBManager

static FMDatabase* sharedInstance;
static DBManager* dbMgr;

- (id)init
{
    self = [super init];
    if (self) {

        [self initSetup];
    }
    return self;
}

- (id)initWithcreateEditableCopyOfDatabaseIfNeeded:(NSString*)name
{
    self = [super init];
    if (self) {
        //   self.dbName = name;
        [self initSetup];
        NSLog(@"Database path %@", [self databasePath]);
        [self createEditableCopyOfDatabaseIfNeeded];
    }
    return self;
}

- (void)initSetup
{
    self.modelMeta = [[DBModelMeta alloc] init];
}

- (NSString*)databasePath
{

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
    return filePath;
}

- (void)openDatabase {}

+ (FMDatabase*)sharedDBInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        
        dbMgr =[[DBManager alloc]init];
        sharedInstance = [FMDatabase databaseWithPath:[dbMgr databasePath]];
        [sharedInstance open];
    });
    return sharedInstance;
}

- (void)closeDatabase
{
    [sharedInstance close];
}

- (void)insertRecord:(DBObject*)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{
    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    Class type = [dataObject class];

    [self.modelMeta modelAddByType:type];

    NSString* pkName = [self.modelMeta modelGetPrimaryKeyName];
    NSString* tableName = [self.modelMeta modelGetTableName];

    NSMutableString* sql = [[NSMutableString alloc] init];
    NSMutableString* paramsSql = [[NSMutableString alloc] init];
    NSMutableArray* paramsArray = [[NSMutableArray alloc] init];
    int index = 0;

    [sql appendString:@"insert into "];

    [sql appendString:tableName];
    [sql appendString:@"("];

    [paramsSql appendString:@" values("];

    int propertyCount = [self.modelMeta propertyCount];
    for (int propertyIndex = 0; propertyIndex < propertyCount; propertyIndex++) {
        [self.modelMeta propertySetCurrentByIndex:propertyIndex];

        //Change Condition to allow pk with values

        if ([self.modelMeta propertyGetIsKey]
                || [self.modelMeta propertyGetIsReadOnly]
                       || [self.modelMeta propertyGetIgnore]) {
            continue;
        }

        if (index > 0) {
            [sql appendString:@","];
            [paramsSql appendString:@","];
        }

        [sql appendString:[self.modelMeta propertyGetColumnName]];

        //Default created method
        BOOL skipColum = NO;

        if ([PWStringUtils isEqual:[self.modelMeta propertyGetColumnName]
                  compareString:@"created"]) {
            [paramsSql appendString:@"?"];
            [paramsArray addObject:[[NSDate alloc] init]];
            skipColum = YES;
        }

        if (!skipColum) {

            id value = [dataObject valueForKey:[self.modelMeta propertyGetName]];
            if (value) {
                [paramsSql appendString:@"?"];
                [paramsArray addObject:value];
            } else {
                [paramsSql appendString:@"null"];
            }
        }
        index++;
    }

    [sql appendString:@")"];
    [paramsSql appendString:@")"];

    [sql appendString:paramsSql];

    FMDatabase* db = [DBManager sharedDBInstance];

    if ([db executeUpdate:sql
            withArgumentsInArray:paramsArray]) {

        NSNumber* insertedId = [NSNumber numberWithUnsignedInteger:(NSInteger)[db lastInsertRowId]];

        if (![PWStringUtils isEmpty:pkName]) {
            [dataObject setValue:insertedId
                          forKey:pkName];
        }

        NSString* msg = [NSString stringWithFormat:@"Record inserted into %@ record id %@", tableName, insertedId];
        NSLog(@"%@", msg);
        [NSNumber numberWithUnsignedInteger:(NSInteger)[db lastInsertRowId]];

        if (self.dbSuccess != nil) {
            self.dbSuccess(insertedId, msg);
        }
        // [db executeQuery:@"commit"];

    } else {

        NSString* msg = [NSString stringWithFormat:@"%@  : %@ : %@", tableName, [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);

        //[Alert show:msg];
        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }
}

- (void)updateRecord:(DBObject*)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    if (!dataObject) {
        return;
    }

    Class type = [dataObject class];
    [self.modelMeta modelAddByType:type];
    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    NSMutableString* sql = [[NSMutableString alloc] init];
    NSMutableArray* paramsArray = [[NSMutableArray alloc] init];

    NSString* pkName = [self.modelMeta modelGetPrimaryKeyName];
    NSString* tableName = [self.modelMeta modelGetTableName];

    [sql appendString:@"update "];
    [sql appendString:tableName];
    [sql appendString:@" set "];

    int propertyCount = [self.modelMeta propertyCount];
    int index = 0;
    for (int propertyIndex = 0; propertyIndex < propertyCount; propertyIndex++) {
        [self.modelMeta propertySetCurrentByIndex:propertyIndex];

        if ([self.modelMeta propertyGetIsKey]
                || [self.modelMeta propertyGetIsReadOnly]
                       || [self.modelMeta propertyGetIgnore]) {
            continue;
        }

        if ([PWStringUtils isEqual:[self.modelMeta propertyGetColumnName]
                  compareString:@"created"]) {
            continue;
        }

        if (index > 0) {
            [sql appendString:@","];
        }

        if ([PWStringUtils isEqual:[self.modelMeta propertyGetColumnName]
                  compareString:@"updated"]) {
            [sql appendString:@"updated"];
            [sql appendString:@" = ?"];
            [paramsArray addObject:[[NSDate alloc] init]];
            index++;
            continue;
        }

        [sql appendString:[self.modelMeta propertyGetColumnName]];

        id value = [dataObject valueForKey:[self.modelMeta propertyGetName]];
        if (value) {
            [sql appendString:@" = ?"];
            [paramsArray addObject:value];
        } else {
            [sql appendString:@" = null"];
        }

        index++;
    }

    [sql appendString:@" where "];
    [sql appendString:pkName];
    [sql appendString:@" = ? "];

    NSNumber* pkValue = (NSNumber*)[dataObject valueForKey:pkName];
    [paramsArray addObject:pkValue];

    FMDatabase* db = [DBManager sharedDBInstance];

    NSLog(@"%@", sql);
    if ([db executeUpdate:sql
            withArgumentsInArray:paramsArray]) {

        NSString* msg = [NSString stringWithFormat:@"Record updated  %@ Pkid %@", tableName, pkValue];

        NSLog(@"%@", msg);

        if (self.dbSuccess != nil) {
            self.dbSuccess(pkValue, msg);
        }

    } else {

        NSString* msg = [NSString stringWithFormat:@"%@  : Pkid %@ : %@ : %@", tableName, pkValue, [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);
        //[Alert show:msg];
        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }
}

- (void)updateRecord2:(DBObject*)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{
    
    if (!dataObject) {
        return;
    }
    
    Class type = [dataObject class];
    [self.modelMeta modelAddByType:type];
    self.dbSuccess = successBlock;
    self.dbFail = failBlock;
    
    NSMutableString* sql = [[NSMutableString alloc] init];
    NSMutableArray* paramsArray = [[NSMutableArray alloc] init];
    
    NSString* pkName = [self.modelMeta modelGetPrimaryKeyName];
    NSString* tableName = [self.modelMeta modelGetTableName];
    
    [sql appendString:@"update "];
    [sql appendString:tableName];
    [sql appendString:@" set "];
    
    int propertyCount = [self.modelMeta propertyCount];
    int index = 0;
    for (int propertyIndex = 0; propertyIndex < propertyCount; propertyIndex++) {
        [self.modelMeta propertySetCurrentByIndex:propertyIndex];
        
        if ([self.modelMeta propertyGetIsKey]
            || [self.modelMeta propertyGetIsReadOnly]
            || [self.modelMeta propertyGetIgnore]) {
            continue;
        }
        
        if ([PWStringUtils isEqual:[self.modelMeta propertyGetColumnName]
                  compareString:@"created"]) {
            continue;
        }
        
        if (index > 0) {
            [sql appendString:@","];
        }
        
        if ([PWStringUtils isEqual:[self.modelMeta propertyGetColumnName]
                  compareString:@"updated"]) {
            [sql appendString:@"updated"];
            [sql appendString:@" = ?"];
            [paramsArray addObject:[[NSDate alloc] init]];
            index++;
            continue;
        }
        
        [sql appendString:[self.modelMeta propertyGetColumnName]];
        
        id value = [dataObject valueForKey:[self.modelMeta propertyGetName]];
        if (value) {
            [sql appendString:@" = ?"];
            [paramsArray addObject:value];
        } else {
            [sql appendString:@" = null"];
        }
        
        index++;
    }
    
    [sql appendString:@" where "];
    [sql appendString:pkName];
    [sql appendString:@" = ? "];
    
    NSNumber* pkValue = (NSNumber*)[dataObject valueForKey:pkName];
    [paramsArray addObject:pkValue];
    
    FMDatabase* db = [DBManager sharedDBInstance];
    
    NSLog(@"%@", sql);
    if ([db executeUpdate:sql
     withArgumentsInArray:paramsArray]) {
        
        NSString* msg = [NSString stringWithFormat:@"Record updated  %@ Pkid %@", tableName, pkValue];
        
        NSLog(@"%@", msg);
        
        if (self.dbSuccess != nil) {
            self.dbSuccess(pkValue, msg);
        }
        
    } else {
        
        NSString* msg = [NSString stringWithFormat:@"%@  : Pkid %@ : %@ : %@", tableName, pkValue, [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);
        //[Alert show:msg];
        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }
}


- (void)deleteRecord:(DBObject*)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    if (!dataObject) {
        return;
    }

    Class type = [dataObject class];
    [self.modelMeta modelAddByType:type];
    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    NSString* tableName = [self.modelMeta modelGetTableName];
    NSString* pkName = [self.modelMeta modelGetPrimaryKeyName];
    NSNumber* pkValue = (NSNumber*)[dataObject valueForKey:pkName];

    NSMutableString* sql = [[NSMutableString alloc] init];
    [sql appendString:@"delete from "];
    [sql appendString:tableName];
    [sql appendString:@" where "];
    [sql appendString:pkName];
    [sql appendString:@" = ? "];

    FMDatabase* db = [DBManager sharedDBInstance];

    if ([db executeUpdate:sql
            withArgumentsInArray:[NSArray arrayWithObject:pkValue]]) {
        NSString* msg = [NSString stringWithFormat:@"Record Deleted  %@ Pkid %@", tableName, pkValue];
        NSLog(@"%@", msg);

        if (self.dbSuccess != nil) {
            self.dbSuccess(pkValue, msg);
        }

    } else {

        NSString* msg = [NSString stringWithFormat:@"%@  : Pkid %@ : %@ : %@", tableName, pkValue, [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);
        //[Alert show:msg];
        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }
}

- (void)deleteRecordSql:(NSString*)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    FMDatabase* db = [DBManager sharedDBInstance];

    if ([db executeUpdate:query]) {
        //      NSString *msg = [NSString stringWithFormat:@"Record Deleted  %@ Pkid %@",tableName, pkValue];
        //     NSLog(@"%@",msg);

        if (self.dbSuccess != nil) {
            //self.dbSuccess(pkValue,msg);
        }

    } else {

        NSString* msg = [NSString stringWithFormat:@"%@  : %@ : %@", query, [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);
        //[Alert show:msg];
        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }
}

- (BOOL)isRecordExists:(Class)type Sql:(NSString*)sqlQuery successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    NSLog(@"Query %@", sqlQuery);

    [self.modelMeta modelAddByType:type];

    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    NSArray* records = [self query:sqlQuery
                    withParameters:nil
                           forType:type
                      successBlock:successBlock
                         failBlock:failBlock];

    if (self.dbSuccess != nil) {

        if ([records count] > 0) {
            NSNumber* pkValue = [[NSNumber alloc] init];
            DBObject* result = [records firstObject];

            if ([result respondsToSelector:@selector(id)]) {
                pkValue = [[records firstObject] id];
            }

            NSString* msg = @"Record exists ";

            self.dbSuccess(pkValue, msg);
        }
    }

    return [records count] == 0 ? NO : YES;
}

- (id)retrieveFirstRecord:(Class)type sqlStatement:(NSString*)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    return [[self retrieveRecordSet:type
                       sqlStatement:sql
                       successBlock:successBlock
                          failBlock:failBlock] firstObject];
}

- (NSArray*)retrieveRecordSet:(Class)type sqlStatement:(NSString*)sqlQuery successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    NSLog(@"Query %@", sqlQuery);

    [self.modelMeta modelAddByType:type];

    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    NSArray* records = [self query:sqlQuery
                    withParameters:nil
                           forType:type
                      successBlock:successBlock
                         failBlock:failBlock];

    return records;
}

- (id)retrieveRecord:(Class)type key:(NSNumber*)key successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    [self.modelMeta modelAddByType:type];

    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    FMDatabase* db = [DBManager sharedDBInstance];
    NSString* tableName = [self.modelMeta modelGetTableName];

    NSString*keyName =[self.modelMeta modelGetPrimaryKeyName];
    
    NSLog(@"Retrieve query : select * from %@ where %@ = %d", tableName, keyName, [key intValue]);
    NSArray* records = [self query:[NSString stringWithFormat:
                                                 @"select * from %@ where %@ = ?", tableName, keyName]
                    withParameters:[NSArray arrayWithObject:key]
                           forType:type
                      successBlock:successBlock
                         failBlock:failBlock];

    if ([records count] != 0) {
        NSString* msg = [NSString stringWithFormat:@"Records retrieved  %@ PkId %@", tableName, key];

        if (self.dbSuccess != nil) {
            self.dbSuccess(key, msg);
        }
    } else {

        if (self.dbFail != nil) {
            self.dbFail([db lastError], [db lastErrorMessage]);
        }
    }

    return [records count] == 0 ? nil : [records objectAtIndex:0];
}

- (NSArray*)query:(NSString*)sql withParameters:(NSArray*)params forType:(Class)type successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock
{

    FMDatabase* db = [DBManager sharedDBInstance];
    NSMutableArray* records = [[NSMutableArray alloc] init];
    FMResultSet* resultSet;

    int count=0;

    self.dbSuccess = successBlock;
    self.dbFail = failBlock;

    if (params == nil) {
        resultSet = [db executeQuery:sql];
    } else {
        resultSet = [db executeQuery:sql
                withArgumentsInArray:params];
    }

    if (self.dbFail != nil) {
        self.dbFail([db lastError], [db lastErrorMessage]);
    }

    // if (![StringUtil isEmpty:[db lastErrorMessage]]) {

    if (resultSet == nil) {
        NSString* msg = [NSString stringWithFormat:@"DBError %@ %@", [db lastError], [db lastErrorMessage]];
        NSLog(@"%@", msg);
        //[Alert show:msg];
    }
    sqlite3_stmt* stat = [resultSet statement].statement;

    [self.modelMeta modelAddByType:type];
    if (stat != nil) {
        NSArray* columns = [DBManager getQueryColumns:stat];

        while ([resultSet next]) {
            id newObject = [self mapRecord:stat
                                andColumns:columns
                                   forType:type];
            [records addObject:newObject];
        }
        count++;
        [resultSet close];
    }

    if (self.dbSuccess != nil) {
        self.dbSuccess([NSNumber numberWithInt:count], [NSString stringWithFormat:@"Number of records %@", [NSNumber numberWithInt:count]]);
    }
    //sqlite3_finalize(stat);

    return records;
}

+ (NSArray*)getQueryColumns:(sqlite3_stmt*)stat
{

    NSMutableArray* propertyArray = [NSMutableArray array];
    int index = 0;

    while (true) {
        const char* name = sqlite3_column_name(stat, index);
        if (name) {
            [propertyArray addObject:[NSString stringWithCString:name
                                                        encoding:NSUTF8StringEncoding]];
        } else {
            break;
        }
        index++;
    }

    return propertyArray;
}

- (id)mapRecord:(sqlite3_stmt*)stat andColumns:(NSArray*)columns forType:(Class)type
{

    int columnIndex;
    id object = [[type alloc] init];

    int propertyCount = [self.modelMeta propertyCount];

    for (int propertyIndex = 0; propertyIndex < propertyCount; propertyIndex++) {
        [self.modelMeta propertySetCurrentByIndex:propertyIndex];

        if ([self.modelMeta propertyGetIgnore]) {
            continue;
        }

        columnIndex = (int)[DBManager indexOfCaseInsensitiveString:
                                          [self.modelMeta propertyGetColumnName]
                                                           inArray:columns];
        if (columnIndex == -1) {
            continue;
        }

        int sqlType = sqlite3_column_type(stat, columnIndex);
        NSString* type = [self.modelMeta propertyGetType];
        id propValue = nil;

        //float or double
        if ([type compare:@"Tf"] == NSOrderedSame || [type compare:@"Td"] == NSOrderedSame) {

            propValue = [NSNumber numberWithFloat:
                                      [DBManager floatForColumnIndex:columnIndex
                                                        andStatement:stat]];

        }
        //int, long, bool, long long

        else if([type compare:@"Ti"]==NSOrderedSame || [type compare:@"Tl"]==NSOrderedSame
                || [type compare:@"Tc"]==NSOrderedSame || [type compare:@"Tq"]==NSOrderedSame){
            
            propValue=[NSNumber numberWithInteger:
                       [DBManager intForColumnIndex:columnIndex andStatement:stat]];
        }
        else if ([type compare:@"T@\"NSString\""]==NSOrderedSame) {
            
            propValue=[DBManager stringForColumnIndex:columnIndex andStatement:stat];
        }
        else if([type compare:@"T@\"NSNumber\""]==NSOrderedSame || [type compare:@"T@\"NSDecimalNumber\""]==NSOrderedSame){
            
            if (sqlType == SQLITE_INTEGER) {
                propValue = [NSNumber numberWithInt:
                                          (int)[DBManager intForColumnIndex:columnIndex
                                                               andStatement:stat]];
            } else if (sqlType == SQLITE_FLOAT) {
                propValue = [NSNumber numberWithFloat:
                                          [DBManager floatForColumnIndex:columnIndex
                                                            andStatement:stat]];
            }
        } else if ([type compare:@"T@\"NSDate\""] == NSOrderedSame) {

            propValue = [DBManager dateForColumnIndex:columnIndex
                                         andStatement:stat];
        }

        if (propValue)
            [object setValue:propValue
                      forKey:[self.modelMeta propertyGetName]];
    }

    return object;
}

+ (NSUInteger)indexOfCaseInsensitiveString:(NSString*)aString inArray:(NSArray*)array
{

    NSUInteger index = 0;
    for (NSString* object in array) {
        if ([object caseInsensitiveCompare:aString] == NSOrderedSame) {
            return index;
        }
        index++;
    }
    return NSNotFound;
}

+ (CGFloat)floatForColumnIndex:(int)columnIdx andStatement:(sqlite3_stmt*)compiledStatement
{
    return sqlite3_column_double(compiledStatement, columnIdx);
}

+ (NSInteger)intForColumnIndex:(int)columnIdx andStatement:(sqlite3_stmt*)compiledStatement
{
    return sqlite3_column_int(compiledStatement, columnIdx);
}

+ (NSString*)stringForColumnIndex:(int)columnIdx andStatement:(sqlite3_stmt*)compiledStatement
{

    if (sqlite3_column_type(compiledStatement, columnIdx) == SQLITE_NULL || (columnIdx < 0)) {
        return @"";
    }
    const char* c = (const char*)sqlite3_column_text(compiledStatement, columnIdx);
    if (!c) {
        // null row.
        return nil;
    }

    return [NSString stringWithUTF8String:c];
}

+ (NSDate*)dateForColumnIndex:(int)columnIdx andStatement:(sqlite3_stmt*)compiledStatement
{
    if (sqlite3_column_type(compiledStatement, columnIdx) == SQLITE_NULL || (columnIdx < 0)) {
        return nil;
    }
    long long dateLong = sqlite3_column_double(compiledStatement, columnIdx);
    if (dateLong == 0) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:dateLong];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded
{

    // First, test for existence.
    BOOL success;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error;

    success = [fileManager fileExistsAtPath:[self databasePath]];

    if (success)
        return;

    // The writable database does not exist, so copy the default to the appropriate location.
    NSString* defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath
                                   toPath:[self databasePath]
                                    error:&error];

    if (!success) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)mergeModelMeta:(DBModelMeta*)meta
{
    [self.modelMeta merge:meta];
}

@end
