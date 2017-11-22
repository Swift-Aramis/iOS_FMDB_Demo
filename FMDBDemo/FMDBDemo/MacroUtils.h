//
//  MacroUtils.h
//  FMDBDemo
//
//  Created by 提运佳 on 2017/8/30.
//  Copyright © 2017年 提运佳. All rights reserved.
//

#ifndef MacroUtils_h
#define MacroUtils_h

#ifdef DEBUG
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif

#define EMPTY_STRING        @""

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#endif /* MacroUtils_h */
