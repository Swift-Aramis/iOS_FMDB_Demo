//
//  ViewController.m
//  FMDBDemo
//
//  Created by 提运佳 on 2017/8/30.
//  Copyright © 2017年 提运佳. All rights reserved.
//

#import "ViewController.h"
#import "MacroUtils.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface ViewController ()

@property (nonatomic,copy) NSString * dbPath;

@end

@implementation ViewController

/**
 *  1.添加libsqlite3.tbd依赖库
    2. -fno-objc-arc使相应FMDB.m文件不使用ARC机制
    3.熟悉常用SQLite命令,详见下列注释
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * doc = PATH_OF_DOCUMENT;
    NSString * path = [doc stringByAppendingPathComponent:@"user.sqlite"];
    self.dbPath = path;
}

#pragma mark - SQL Operations

- (IBAction)createTableAction:(UIButton *)sender {
    debugMethod();
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.dbPath])  {
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            /**
             *  这条命令是创建一个User的表，并将id字段设为primary key主键,将其指定为一个autoincrement自动增长的字段。表示不用提供id的值，数据库将字段生成。name,password 表示该表中所含有的字段。
             */
            NSString * sql = @"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'password' VARCHAR(30))";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                debugLog(@"error when creating db table");
            } else {
                debugLog(@"succ to creating db table");
            }
            [db close];
            
        } else {
            debugLog(@"error when open db");
        }
    }
}

- (IBAction)InsertAction:(UIButton *)sender {
    static int idx = 1;
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        /**
         *  这样成功往user表成功的插入了一条数据
         */
        NSString * sql = @"insert into user (name, password) values(?, ?) ";
        NSString * name = [NSString stringWithFormat:@"tiyunjia%d", idx++];
        BOOL res = [db executeUpdate:sql, name, @"boy"];
        if (!res) {
            debugLog(@"error to insert data");
        } else {
            debugLog(@"succ to insert data");
        }
        [db close];
    }
}

- (IBAction)QueryAction:(UIButton *)sender {
    debugMethod();
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        /**
         *  查询user表中的所有数据
         */
        NSString * sql = @"select * from user";
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            int userId = [rs intForColumn:@"id"];
            NSString * name = [rs stringForColumn:@"name"];
            NSString * pass = [rs stringForColumn:@"password"];
            debugLog(@"user id = %d, name = %@, pass = %@", userId, name, pass);
        }
        [db close];
    }
}

- (IBAction)ClearAllAction:(UIButton *)sender {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        /**
         *  删除user表中的所有数据
         */
        NSString * sql = @"delete from user";
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            debugLog(@"error to delete db data");
        } else {
            debugLog(@"succ to deleta db data");
        }
        [db close];
    }
}

- (IBAction)multiThreadAction:(UIButton *)sender {
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
        for (int i = 0; i < 100; ++i) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString * sql = @"insert into user (name, password) values(?, ?) ";
                NSString * name = [NSString stringWithFormat:@"queue111 %d", i];
                BOOL res = [db executeUpdate:sql, name, @"boy"];
                if (!res) {
                    debugLog(@"error to add db data: %@", name);
                } else {
                    debugLog(@"succ to add db data: %@", name);
                }
            }];
        }
    });
    
    dispatch_async(q2, ^{
        for (int i = 0; i < 100; ++i) {
            [queue inDatabase:^(FMDatabase *db) {
                NSString * sql = @"insert into user (name, password) values(?, ?) ";
                NSString * name = [NSString stringWithFormat:@"queue222 %d", i];
                BOOL res = [db executeUpdate:sql, name, @"boy"];
                if (!res) {
                    debugLog(@"error to add db data: %@", name);
                } else {
                    debugLog(@"succ to add db data: %@", name);
                }
            }];
        }
    });
}


@end
