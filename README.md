###FMDB-ORM


A ORM wrapper around the FMDB library that provides an ORM layer for user-space objects in any iOS iPhone/iPad app.


###Getting Started

To get started, add the **libsqlite3.0.dylib** framework to your project. Then copy the following files to your project:

###Working with Objects

* The class name must be the same as the table name
* A primary key is required, must be an integer and must be named [table-name]id

Given the following object:

	@interface DBContact : DBObject
	@property int contactId;
	@property(copy)NSString*fullName;
	@property(strong)NSDate* createdOn;
	@end
	
	@implementation Contact
	//assume ARC and auto-syn properties
	@end
	
and schema:

	CREATE TABLE contact
	(
		contactid INTEGER PRIMARY KEY, 
		fullName TEXT, 
		addedOn NUMBER
	)

###Insert Record

	DBManger *dbMgr = [DBManager alloc]init];
	DBContact *contact = [DBContact alloc]init];
	
	contact.fullName = @"Name of the person";
	
	//contact.id = Auto generate id
	//contact.createdOn - Auto stamped the date and time of the date created
	
  [dbMgr insertRecord:contact
                   successBlock:^(NSNumber *pkId, NSString *msg) {
				   
				   //pkId - Primaey key id of the inserted record
				   
				   //Optional Msg = "New Contact created in the database"
				   }
                      failBlock:^(NSError *error, NSString *errMsg) {
						  
						  //if insert record fail then this blocks invokes with error id and error message
						  
						  }];

### Update Record



	DBManger *dbMgr = [DBManager alloc]init];
	DBContact *contact = [DBContact alloc]init];
	
	contact.fullName = @"Name of the person";
	contact.id = 2;
	
[dbMgr updateRecord:contact
                   successBlock:^(NSNumber *pkId, NSString *msg) {
					   
					   //pkid - updated record id
					   //msg - Contact name updated
				   }
                      failBlock:^(NSError *error, NSString *errMsg) {
						  //if update record fail then this blocks invokes with error id and error message
					}];

Other Api Methods


### Delete Record


-(void) deleteRecord:(DBObject *)dataObject successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;


### To check record exists

-(BOOL) isRecordExists:(Class)type Sql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

### Delete record based on the sql with multiple where condition

-(void) deleteRecordSql:(NSString *)query successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

### Retrieve Record based on the primary Key

-(id) retrieveRecord:(Class)type key:(NSNumber *)key successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

### Retrieve Multiple record set based on the sql

-(NSArray *) retrieveRecordSet:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;

###Returns first record of the record set

-(id ) retrieveFirstRecord:(Class)type sqlStatement: (NSString *)sql successBlock:(DBSuccess)successBlock failBlock:(DBFail)failBlock;
