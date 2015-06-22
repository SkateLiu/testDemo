//
//  UserDataModel.m
//  BodyScaleProduction
//
//  Created by Go Salo on 14-3-18.
//  Copyright (c) 2014年 Go Salo. All rights reserved.
//

#import "UserDataModel.h"
#import "HTTPService.h"

@implementation UserDataModel


-(int)getRequest:(NSString *)rStr
{
    int _request = 10005;
    if (rStr && ![rStr isKindOfClass:[NSNull class]]) {
        _request = [rStr intValue];
    }
    return _request;
}

- (void)requestSubmitDimensionalCodeWithdimensionalCode: (NSString *)dimensionalCode
                                                   imei: (NSString *)imei{
    NSString *sign = [[dimensionalCode stringByAppendingString:imei]stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:dimensionalCode forKey:@"dimensionalCode"];
    [param setObject:imei forKey:@"imei"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSubmitDimensionalCode
                          parameters:param
                             success:^(id task, id responseObject){
                                 if([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]){
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_DIMENSIONAL_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_DIMENSIONAL_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)queryDimensionalCodeWithdimensionalCode:(NSString *)dimensionalCode
{
    NSString *sign = [dimensionalCode stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:dimensionalCode forKey:@"dimensionalCode"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQueryDimensionalCode_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_DIMENSIONAL_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_DIMENSIONAL_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestSubmitMeasurementDataWithsessionId:(NSString *)sessionId
                                           userId:(NSString *)userId
                                           weight:(double)weight
                                              bmi:(double)bmi
                                              fat:(double)fat
                                          skinfat:(double)skinfat
                                         offalfat:(double)offalfat
                                           muscle:(double)muscle
                                       metabolism:(double)metabolism
                                            water:(double)water
                                             bone:(double)bone
                                          bodyage:(double)bodyage
                                           longit:(NSString *)longit
                                            latit:(NSString *)latit
                                          devcode:(NSString *)devcode
                                         location:(NSString *)location
                                        checkdate:(NSString *)checkdate{

    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:[NSNumber numberWithDouble:weight] forKey:@"weight"];
    [param setObject:[NSNumber numberWithDouble:bmi] forKey:@"bmi"];
    [param setObject:[NSNumber numberWithDouble:fat] forKey:@"fat"];
    [param setObject:[NSNumber numberWithDouble:skinfat] forKey:@"skinfat"];
    [param setObject:[NSNumber numberWithDouble:offalfat] forKey:@"offalfat"];
    [param setObject:[NSNumber numberWithDouble:muscle] forKey:@"muscle"];
    [param setObject:[NSNumber numberWithDouble:metabolism] forKey:@"metabolism"];
    [param setObject:[NSNumber numberWithDouble:water] forKey:@"water"];
    [param setObject:[NSNumber numberWithDouble:bone] forKey:@"bone"];
    [param setObject:[NSNumber numberWithDouble:bodyage] forKey:@"bodyage"];

    [param setObject:longit forKey:@"longit"];
    [param setObject:latit forKey:@"latit"];
    
    
    [param setObject:devcode forKey:@"devcode"];
    [param setObject:location forKey:@"location"];
    
    [param setObject:checkdate forKey:@"checkdate"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSubmitMeasurementData_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_DATA_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_DATA_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestQueryMeasurementDataWithsessionId:(NSString *)sessionId
                                          userId:(NSString *)userId
                                        dateType:(NSString *)dateType
                                       beginDate:(NSString *)beginDate
                                         endDate:(NSString *)endDate{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:dateType forKey:@"dateType"];
    [param setObject:beginDate forKey:@"beginDate"];
    [param setObject:endDate forKey:@"endDate"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQueryMeasurementData_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_DATA_CODE
                                                            info:responseObject
                                                     requestInfo:param];

                                 }
                                 
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_DATA_CODE
                                                        info:error
                                                 requestInfo:param];

                             }];
}

- (void)requestQueryLatestMeasurementDataWithsessionId:(NSString *)sessionId
                                           latestIndex:(NSString *)latestIndex{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:latestIndex forKey:@"latestIndex"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQueryLatestMeasurementData_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_LATEST_DATA_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_LATEST_DATA_CODE
                                                        info:error
                                                 requestInfo:param];

                             }];
}

- (void)requestSettingWithsessionId:(NSString *)sessionId
                             userId:(NSString *)userId
                               mode:(NSString *)mode
                               plan:(NSString *)plan
                             target:(NSString *)target
                            privacy:(NSString *)privacy
                        remindcycle:(NSString *)remindcycle
                         remindmode:(NSString *)remindmode{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:mode forKey:@"mode"];
    [param setObject:plan forKey:@"plan"];
    [param setObject:target forKey:@"target"];
    [param setObject:privacy forKey:@"privacy"];
    [param setObject:remindcycle forKey:@"remindcycle"];
    [param setObject:remindmode forKey:@"remindmode"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSetting_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:USER_SETTING_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:USER_SETTING_CODE
                                                        info:error
                                                 requestInfo:param];

                             }];
}

- (void)requestQuerySettingWithsessionId:(NSString *)sessionId userId:(NSString *)userId
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQuerySetting_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_SETTING_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_SETTING_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestSubmitSuggestWithsessionId:(NSString *)sessionId content:(NSString *)content
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:content forKey:@"content"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSubmitSuggest_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_SUGGEST_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_SUGGEST_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestQuerySuggestWithsessionId:(NSString *)sessionId
                                  userId:(NSString *)userId
                                userInfo:(id)userInfo
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQuerySuggest_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     if (userInfo) {
                                         [param setObject:userInfo forKey:@"userInfo"];
                                     }
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_SUGGEST_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_SUGGEST_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
    
}

- (void)requestSubmitPraiseWithsessionId:(NSString *)sessionId
                                  userId:(NSString *)userId
                                    type:(NSString *)type
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:type forKey:@"type"];
    
    [param setObject:[sign md5String] forKey:@"sign"];
    
    [[HTTPService sharedClient] POST:BodyScaleSubmitPraise_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     

                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_PRAISE_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_PRAISE_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestQueryPraiseWithsessionId:(NSString *)sessionId
                                  userId:(NSString *)userId
                                    type:(NSString *)type
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:type forKey:@"type"];
    
    [param setObject:[sign md5String] forKey:@"sign"];
    
    [[HTTPService sharedClient] POST:BodyScaleQueryPraise_URL
                          parameters:param
                             success:^(id task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_PRAISE_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(id task, NSError *error){
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_PRAISE_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}


- (void)requestQueryDevCodeWithsessionId:(NSString *)sessionId
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQueryDevCode_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:QUERY_DEV_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_DEV_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}


- (void)requestSubmitBatchDataWithsessionId:(NSString *)sessionId
                                   jsonData:(NSString *)jsonData
                                       list:(NSString *)list
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:jsonData forKey:@"jsonDataList"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSubmitBatchData_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_BATCH_DATA_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_BATCH_DATA_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestCancelBindWithsessionId:(NSString *)sessionId
                               devCode:(NSString *)devCode
                                bindId:(NSString *)bindId
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:devCode forKey:@"devCode"];
    if (bindId) {
        [param setObject:bindId forKey:@"bindId"];
    }
    
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleCancelBind_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:CANCEL_BIND_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:CANCEL_BIND_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestSubmitBindWithsessionId:(NSString *)sessionId
                               devCode:(NSString *)devCode
                              location:(NSString *)location
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:devCode forKey:@"devCode"];
    [param setObject:location forKey:@"location"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleSubmitBind_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:SUBMIT_BIND_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 [self.delegate responseCode:result
                                                    actionId:SUBMIT_BIND_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}

- (void)requestModifyPasswordWithSessionId: (NSString *)sessionId
                              userPassword: (NSString *)userPassword
                               newPassword: (NSString *)newPassword
{

    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSDictionary *param = @{
                            @"sessionId": sessionId,
                            @"loginPwd": [NSString encrypt:userPassword],
                            @"newPwd":[NSString encrypt:newPassword],
                            @"sign":[sign md5String]
                            };
    [[HTTPService sharedClient] POST:BodyScaleModifyPassword_URL
                          parameters:param
                             success:^(NSURLSessionDataTask *task, id responseObject){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     [self.delegate responseCode:result
                                                        actionId:MODIFY_PWD_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                             }failure:^(NSURLSessionDataTask *task, NSError *error){
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = REQUEST_FAILURE_CODE;
                                     [self.delegate responseCode:result
                                                        actionId:MODIFY_PWD_CODE
                                                            info:error
                                                     requestInfo:param];
                                 }
                             }];
    
    
}

- (void)requestQueryFocusDataWithsessionId:(NSString *)sessionId
                                    userId:(NSString *)userId
                                  userInfo:(id)userInfo
{
    NSString *sign = [sessionId stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:userId forKey:@"userId"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleQueryFocusData_URL
                         parameters:param
                         success:^(id task, id responseObject) {
                             if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                 
                                 int result = [self getRequest:responseObject[@"result"]];
                                 
                                 
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 
                                 [self.delegate responseCode:result
                                                    actionId:QUERY_FOCUS_DATA_CODE
                                                        info:responseObject
                                                 requestInfo:param];
                             }

                         } failure:^(id task, NSError *error) {
                             int result = REQUEST_FAILURE_CODE;
                             
                             if (userInfo) {
                                 [param setObject:userInfo forKey:@"userInfo"];
                             }
                             
                             [self.delegate responseCode:result
                                                actionId:QUERY_FOCUS_DATA_CODE
                                                    info:error
                                             requestInfo:param];
                         }];
}


/**
 *  删除单条数据
 *
 *  @param sessionId 会话id
 *  @param dataId    UserDataEntity－>UD_ID
 *  @param userInfo  用户信息
 */
- (void)requestDeleteDataWithsessionId:(NSString *)sessionId
                                dataId:(NSNumber *)dataId
                                reason:(NSString *)reason
                              userInfo:(id)userInfo
{
    NSString *sign = [[sessionId stringByAppendingString:[dataId stringValue] ]stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:sessionId forKey:@"sessionId"];
    [param setObject:dataId forKey:@"dataId"];
    [param setObject:reason forKey:@"reason"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleDeleteData_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     
                                     if (userInfo) {
                                         [param setObject:userInfo forKey:@"userInfo"];
                                     }
                                     
                                     [self.delegate responseCode:result
                                                        actionId:DELETE_DATA_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                                 
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 
                                 [self.delegate responseCode:result
                                                    actionId:DELETE_DATA_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}


/**
 *  验证 验证码是否有效
 *
 *  @param loginName 用户名
 *  @param checkCode 验证码
 *  @param userInfo  用户信息
 */
- (void)requestCheckCodeInvalidWithLoginName:(NSString *)loginName
                                   checkCode:(NSString *)checkCode
                                    userInfo:(id)userInfo
{
    NSString *sign = [[loginName stringByAppendingString:checkCode]stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:loginName forKey:@"loginName"];
    [param setObject:checkCode forKey:@"checkCode"];
    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleCheckCodeInvalid_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     
                                     if (userInfo) {
                                         [param setObject:userInfo forKey:@"userInfo"];
                                     }
                                     
                                     [self.delegate responseCode:result
                                                        actionId:CHECKCODE_INVALID_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                                 
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 
                                 [self.delegate responseCode:result
                                                    actionId:CHECKCODE_INVALID_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}


/**
 *  根据mac地址获取设备颜色
 *
 *  @param mac      设备mac地址
 *  @param userInfo 用户信息
 */
-(void)requestGetDevColorWithMac:(NSString *)mac
                        userInfo:(id)userInfo
{
    NSString *sign = [mac stringByAppendingString:APPOINT_KEY];
    NSMutableDictionary *param = [self getPublicParamWithDateString:[self currentDateString]];
    [param setObject:mac forKey:@"mac"];

    [param setObject:[sign md5String] forKey:@"sign"];
    [[HTTPService sharedClient] POST:BodyScaleGetDevColor_URL
                          parameters:param
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     
                                     if (userInfo) {
                                         [param setObject:userInfo forKey:@"userInfo"];
                                     }
                                     
                                     [self.delegate responseCode:result
                                                        actionId:GET_DEVCOLOR_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                                 
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 
                                 [self.delegate responseCode:result
                                                    actionId:GET_DEVCOLOR_CODE
                                                        info:error
                                                 requestInfo:param];
                             }];
}



/**
 *  上传jd数据～
 *
 *  @param data     jd数据对象
 *  @param user     jd用户对象
 *  @param userInfo 用户信息
 */
- (void)requestUploadJDDataWithData:(JDDataEntity *)data
                               user:(JDUserInfoEntity *)user
                           userInfo:(id)userInfo
{

    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];

    [[HTTPService sharedClient] POST:[JDPlusModel uploadData:data user:user]
                          parameters:nil
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                     
                                     NSLog(@"requestUploadJDDataWithData responseObject:%@",responseObject);
                                     
                                     /*
                                     int result = [self getRequest:responseObject[@"result"]];
                                     
                                     
                                     if (userInfo) {
                                         [param setObject:userInfo forKey:@"userInfo"];
                                     }
                                     
                                     [self.delegate responseCode:result
                                                        actionId:JD_UPLOAD_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                      */
                                 }
                                 
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;
                                 
                                 if (userInfo) {
                                     [param setObject:userInfo forKey:@"userInfo"];
                                 }
                                 
                                 [self.delegate responseCode:result
                                                    actionId:JD_UPLOAD_CODE
                                                        info:error.description
                                                 requestInfo:param];
                             }];
}


/**
 *  获取商品信息
 */
-(void)requestGetProductInfo
{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    [[HTTPService sharedClient] POSTWithFullURL:kGetProductInfo_URL
                          parameters:nil
                             success:^(id task, id responseObject) {
                                 if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {

                                     [self.delegate responseCode:REQUEST_SUCCESS_CODE
                                                        actionId:GET_PROUDCTINFO_CODE
                                                            info:responseObject
                                                     requestInfo:param];
                                 }
                                 
                             } failure:^(id task, NSError *error) {
                                 int result = REQUEST_FAILURE_CODE;

                                 
                                 [self.delegate responseCode:result
                                                    actionId:GET_PROUDCTINFO_CODE
                                                        info:error.description
                                                 requestInfo:param];
                             }];
}



-(void)requestGetOrderNum:(NSDictionary *)param
{
    //NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    
    

    [[HTTPService sharedClient] POSTWithFullURL:kGetOrderInfo_URL
                                     parameters:param
                                        success:^(id task, id responseObject) {
                                            if ([self.delegate respondsToSelector:@selector(responseCode:actionId:info:requestInfo:)]) {
                                                int result = [self getRequest:responseObject[@"code"]];
                                                //NSLog(@"responseObject:%@",responseObject);
                                                
                                                
                                                [self.delegate responseCode:result
                                                                   actionId:GET_ORDERINFO_CODE
                                                                       info:responseObject
                                                                requestInfo:param];
                                            }
                                            
                                        } failure:^(id task, NSError *error) {
                                            int result = REQUEST_FAILURE_CODE;
                                            
                                            
                                            [self.delegate responseCode:result
                                                               actionId:GET_ORDERINFO_CODE
                                                                   info:error.description
                                                            requestInfo:param];
                                        }];
}

-(void)requestWXGetAccessTokenWithUrl:(NSString *)url
{
    [[HTTPService sharedClient] GETWithFullURL:url
                                    parameters:nil
                                       success:^(id task, id responseObject) {
                                           
                                           [self.delegate responseCode:REQUEST_SUCCESS_CODE
                                                              actionId:WX_GET_ACCESSTOKEN_CODE
                                                                  info:responseObject
                                                           requestInfo:nil];
                                           
                                           
                                       }
                                       failure:^(id task, NSError *error) {
                                           int result = REQUEST_FAILURE_CODE;
                                           
                                           
                                           [self.delegate responseCode:result
                                                              actionId:WX_GET_ACCESSTOKEN_CODE
                                                                  info:error.description
                                                           requestInfo:nil];
                                       }];
}


-(void)requestWXGetPrepayIdWithUrl:(NSString *)url
                            params:(NSDictionary *)param
{
    [[HTTPService sharedClient] POSTWithFullURL:url
                                     parameters:nil
                                        success:^(id task, id responseObject) {
                                            
                                            [self.delegate responseCode:REQUEST_SUCCESS_CODE
                                                               actionId:WX_GET_ACCESSTOKEN_CODE
                                                                   info:responseObject
                                                            requestInfo:nil];
                                            
                                            
                                        }
                                        failure:^(id task, NSError *error) {
                                            int result = REQUEST_FAILURE_CODE;
                                            
                                            
                                            [self.delegate responseCode:result
                                                               actionId:WX_GET_ACCESSTOKEN_CODE
                                                                   info:error.description
                                                            requestInfo:nil];
                                        }];
}

@end