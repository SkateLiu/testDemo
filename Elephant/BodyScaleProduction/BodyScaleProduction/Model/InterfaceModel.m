//
//  InterfaceModel.m
//  BodyScaleProduction
//
//  Created by Go Salo on 14-3-21.
//  Copyright (c) 2014年 Go Salo. All rights reserved.
//

#import "InterfaceModel.h"
#import "UserInfomationModel.h"
#import "UserDataModel.h"
#import "JDPlusModel.h"
#import "BuyRyFitInfo.h"

#import "DatabaseService.h"
#import "GloubleProperty.h"
#import "AppDelegate.h"
#import "Helpers.h"

static UserInfomationModel  *_userInfomationModel;
static UserDataModel        *_userDataModel;

@implementation InterfaceModel {
    LoginCallBack                   _loginCallBack;
    GetCheckCodeCallBack            _getCheckCodeCallBack;
    RegisterCallBack                _registerCallBack;
    GetUserDataCallBack             _getUserDataCallBack;
    UpdateUserInfoCallBack          _updateUserInfoWithCallBack;
    UpdateUserSettingCallBack       _updateUserSettingCallBack;
    UpLoadImageCallBack             _upLoadImageCallBack;
    UpLoadImage_updateInfoCallBack  _upLoadImage_updateInfoCallBack;
    DownLoadImageCallBack           _downLoadImageCallBack;
    UserLogoutCallBack             _userLogoutCallBack;
    SubmitUserDataCallBack          _submitUserDataCallBack;
    SubmitSuggestCallBack           _submitSuggestCallBack;
    QuerySuggestCallBack            _querySuggestCallBack;
    QueryNowNoticeCallBack          _queryNowNoticeCallBack;
    
    
    WebCallBack             _queryNoticeCallBack;
    WebCallBack             _queryLatestUserInfoCallBack;
    WebCallBack             _requestChangePWDCallBack;
    WebCallBack             _requestResetPWDCallBack;
    WebCallBack             _getSoleDeviceCodeCallBack;
    WebCallBack             _submitBindCallBack;
    WebCallBack             _cancelBindCallBack;
    WebCallBack             _submitBatchDataCallBack;
    WebCallBack             _deleteDataCallback;
    
    WebRequestCallBack             _queryFriendCallBack;
    WebRequestCallBack             _queryARFriendCallBack;
    WebRequestCallBack             _addFriendWithFriendLonginNameCallBack;
    WebRequestCallBack             _submitPraiseCallBack;
    WebRequestCallBack             _queryPraiseCallBack;
    WebRequestCallBack             _modifyFriendRightCallBack;
    WebRequestCallBack             _deleteFriendCallBack;
    WebRequestCallBack             _getUserSettingCallBack;
    WebRequestCallBack             _getMSGCallBack;
    WebRequestCallBack             _focusSetCallBack;
    WebRequestCallBack             _getFocusMeListCallBack;
    WebRequestCallBack             _setMsgReadedCallBack;
    WebRequestCallBack             _delMsgCallBack;
    WebRequestCallBack             _checkCodeInvalidCallBack;
    WebRequestCallBack             _getProductInfoCallback;
    WebRequestCallBack             _getOrderInfoCallback;
    
    GetDevColorCallBack            _getDevColorCallback;
    CheckLoginNameCallBack         _checkLoginNameCallBack;
    
    JingDongLoginCallback          _jdLonginCallback;
    JingDongGetUserInfoCallback    _jdGetUserInfoCallback;
    
    
    WXPayWebRequestCallback        _wxPayGetAccessTokenCallback;
    WXPayWebRequestCallback        _wxPayGetPrepayIdCallback;
    
    

    JDUserInfo *_tempJDUser;
    
    NSString *_tempSid;
    
    
    CLLocationManager   *_locManager;

    
    int             _locNotOpenAlertIsShow;
    
    NSMutableDictionary *_checkDataDic;
    UIAlertView *_checkDataAlt;
    
    
    
    NSDate *_loginDate;
    
    int _isReLogin;
    int _isLogin;
    
    
    int _loginState;
}

+ (instancetype)sharedInstance {
    
    static InterfaceModel *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _sharedClient           = [[InterfaceModel alloc] init];
        _userInfomationModel    = [[UserInfomationModel alloc] initWithDelegate:_sharedClient];
        _userDataModel          = [[UserDataModel alloc] initWithDelegate:_sharedClient];
        _sharedClient->_isReLogin   = 0;
        _sharedClient->_isLogin     = 0;
        _sharedClient->_loginState  = 0;
  
    });
    
    return _sharedClient;
}


#pragma mark - 辅助

-(BOOL)isOnLogIn
{
    BOOL _flag = NO;
    if (_loginDate) {
        double _seconds = [[NSDate date]  timeIntervalSinceDate:_loginDate];
        float  _minutes = _seconds / 60.0;
        
        
        if (_minutes < 20) {
            _flag = YES;
        }
        if (!_flag ) {
            [self reLogin:@"isOnLogIn"];
        }
        else{
        
            if ([self getLoginState]) {

                [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                                   object:[GloubleProperty sharedInstance].currentUserEntity
                                                                 userInfo:nil];
            }
            else{

                [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataFailure
                                                                   object:[GloubleProperty sharedInstance].currentUserEntity
                                                                 userInfo:nil];
            }
        }
    }else{
        if ([self getLoginState]) {

            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                               object:[GloubleProperty sharedInstance].currentUserEntity
                                                             userInfo:nil];
        }
        else{

            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataFailure
                                                               object:[GloubleProperty sharedInstance].currentUserEntity
                                                             userInfo:nil];
        }
    
    }
    
    
    
    return _flag;
}


-(void)reLogin:(NSString *)idName
{
    if (_isReLogin == 0 && _isLogin ==  0) {
        _isReLogin = 1;
        NSLog(@"-------------%@,引起超时",idName);
        [self showHUDInWindowJustWithText:@"登录超时，正在重新登录"];
        GloubleProperty *_gp    = [GloubleProperty sharedInstance];
        UserInfoEntity *_user   = _gp.currentUserEntity;
        [self userLoginWithLoginName:[self inputStr:_user.UI_loginName]
                            loginPwd:[self inputStr:_user.UI_loginPwd]
                           isEncrypt:YES
                             userLoc:_user.UI_isLoc
                            callBack:nil];
    }
    
}

-(NSString *)inputStr:(id)ipStr
{
    NSString *_result = @"";
    
    if (ipStr == nil || ipStr == NULL) {
        return _result = @"";
    }
    if ([ipStr isKindOfClass:[NSNull class]]) {
        return _result = @"";
    }
    
    if ([ipStr isKindOfClass:[NSString class]]) {
        _result = ipStr;
    }
    
    if ([ipStr isKindOfClass:[NSNumber class]]) {
        _result = [(NSNumber *)ipStr stringValue];
    }
    
    return _result;
}

-(void)fillWebErrorParam:(WebRequestCallBack)callback
                errorObj:(id)eObj
{
    if (callback) {
        
        NSString *_str = @"未知类型错误";
        if (eObj) {
            if ([eObj isKindOfClass:[NSDictionary class]]) {
                
                _str = [self inputStr:eObj[@"errorMsg"]];
                callback(WebCallBackResultFailure,nil,_str);
            }
            else if ([eObj isKindOfClass:[NSError class]]){
                
                //_str = [self inputStr:[(NSError *)eObj description]];
                callback(WebCallBackResultFailure,eObj,@"网络异常，请求失败");
            }
            else if ([eObj isKindOfClass:[NSString class]]){
                
                _str = [self inputStr:eObj];
                callback(WebCallBackResultFailure,nil,_str);
            }
            else{
            
                callback(WebCallBackResultFailure,nil,_str);
            }

        }else{
        
            callback(WebCallBackResultFailure,nil,_str);
        }
   
    }
}

-(void)fillWebSuccessParam:(WebRequestCallBack)callback
                successObj:(id)eObj
{
    if (callback) {

        callback(WebCallBackResultSuccess,eObj,nil);
    }
}

-(void)showAlert:(NSString *)msg
{
    /*
    UIAlertView *_alt = [[UIAlertView alloc]initWithTitle:@"调试用~"
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"ok"
                                        otherButtonTitles: nil];
    [_alt show];
    */
}

-(void)longinTest:(UserInfoEntity *)user
{
    /*
    [self checkLoginNameWithName:@"13816980564"
                        callback:^(WebCallBackResult result, BOOL isUsed, NSString *errorMsg) {
                            NSLog(@"aaa");
                        }];
    */
    /*
    NSDictionary *_dic =  [self getUserDataByYear3:[NSDate date]];
    
    NSLog(@"_dic:%@",_dic);
    NSLog(@"aaa");
     */
    /*
    [self getDevColorWithMac:@"aaa" callback:^(WebCallBackResult result, DevColor color, NSString *errorMsg) {
        NSLog(@"");
    }];
     */
    //[_userDataModel requestGetOrderNum];
//    [[DatabaseService defaultDatabaseService]save200DataInfo:user.UI_userId];
    /*
    [self getCurrentUserTotalDataByPageId:0 callback:^(NSArray *dataList) {
        NSLog(@"page:0,dataList:%@",dataList);
    }];
    
    
    [self getCurrentUserTotalDataByPageId:1 callback:^(NSArray *dataList) {
        NSLog(@"page:1,dataList:%@",dataList);
    }];
    
    
    [self getCurrentUserTotalDataByPageId:2 callback:^(NSArray *dataList) {
        NSLog(@"page:2,dataList:%@",dataList);
    }];
    
    
    [self getCurrentUserTotalDataByPageId:3 callback:^(NSArray *dataList) {
        NSLog(@"page:3,dataList:%@",dataList);
    }];
    
    */
    
    
    /*
    
    UserDataEntity *_ud = [[UserDataEntity alloc]init];
    _ud.UD_ID =@"524";
[self deleteDataWithData:_ud callback:nil];
     */
    //[self getUserDataWithCallBack:nil];
    //[self getUserDataByYear:[NSDate date]];
    //NSArray *_ary = [self getUserDataByDay:[Helpers getDateByString:@"2014-04-17 00:00:00"]];
    //NSArray *_ary = [self getUserDataByMonth:[Helpers getDateByString:@"2014-04-19 00:00:00"]];
    //NSLog(@"aaaa");
    //[self getNowSuggest];
    
    /*
    NSDictionary *_dic = [self getUserDataByDay2:[Helpers getDateByString:@"2014-06-06 00:00:00"]];
    
    NSArray *_objAry = _dic[kIMDateListKey];
    for (int i = 0 ; i < _objAry.count ; i++) {
        UserDataEntity *_ud = _objAry[i];
        NSLog(@"ud-rf:%@,bodyAge:%@,off:%@,bmi:%@",_ud.UD_ryFit ,_ud.UD_BODYAGE,_ud.UD_OFFALFAT,_ud.UD_BMI);
    }
    NSLog(@"_dicDayMax:%@",_dic[kIMDateMaxListKey]);
    NSLog(@"_dicDayMin:%@",_dic[kIMDateMinListKey]);
    
    
    
    _dic = [self getUserDataByWeek2:[Helpers getDateByString:@"2014-04-17 00:00:00"]];
    _objAry = _dic[kIMDateListKey];
    for (int i = 0 ; i < _objAry.count ; i++) {
        UserDataEntity *_ud = _objAry[i];
        NSLog(@"ud-rf:%@,bodyAge:%@,off:%@,bmi:%@",_ud.UD_ryFit ,_ud.UD_BODYAGE,_ud.UD_OFFALFAT,_ud.UD_BMI);
    }
    NSLog(@"_dicWeekyMax:%@",_dic[kIMDateMaxListKey]);
    NSLog(@"_dicWeekMin:%@",_dic[kIMDateMinListKey]);
    
    _dic = [self getUserDataByMonth2:[Helpers getDateByString:@"2014-04-19 00:00:00"]];
    _objAry = _dic[kIMDateListKey];
    for (int i = 0 ; i < _objAry.count ; i++) {
        UserDataEntity *_ud = _objAry[i];
       NSLog(@"ud-rf:%@,bodyAge:%@,off:%@,bmi:%@",_ud.UD_ryFit ,_ud.UD_BODYAGE,_ud.UD_OFFALFAT,_ud.UD_BMI);
    }
    NSLog(@"_dicMonthMax:%@",_dic[kIMDateMaxListKey]);
    NSLog(@"_dicMonthMin:%@",_dic[kIMDateMinListKey]);
    
    
    
    
    _dic = [self getUserDataByYear2:[Helpers getDateByString:@"2014-04-19 00:00:00"]];
    _objAry = _dic[kIMDateListKey];
    for (int i = 0 ; i < _objAry.count ; i++) {
        UserDataEntity *_ud = _objAry[i];
        NSLog(@"ud-rf:%@,bodyAge:%@,off:%@,bmi:%@",_ud.UD_ryFit ,_ud.UD_BODYAGE,_ud.UD_OFFALFAT,_ud.UD_BMI);
    }
    NSLog(@"_dicYearMax:%@",_dic[kIMDateMaxListKey]);
    NSLog(@"_dicYearMin:%@",_dic[kIMDateMinListKey]);
    
    NSLog(@"aaa");
    */
}


#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    [GloubleProperty sharedInstance].lng =
                [NSString stringWithFormat:@"%lf",newLocation.coordinate.longitude];
    [GloubleProperty sharedInstance].lat =
                [NSString stringWithFormat:@"%lf",newLocation.coordinate.latitude];

    [manager stopUpdatingLocation];
   
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];

    switch([error code]) {
        case kCLErrorDenied:
        {
            if (!_locNotOpenAlertIsShow) {
                _locNotOpenAlertIsShow = 1;
                
                [self showHUDInWindowJustWithText:@"定位服务未开启" disMissAfterDelay:0.5];
                
            }
        }
            break;
        case kCLErrorLocationUnknown:
        {
            //NSLog(@"kCLErrorLocationUnknown");
        }
            break;
        default:
        {
            //NSLog(@"location error default");
        }
            break;
    }
}





#pragma mark -网络请求
- (void)userLoginWithLoginName:(NSString *)loginName
                      loginPwd:(NSString *)loginPwd
                     isEncrypt:(BOOL)isEncrypt
                       userLoc:(NSString *)userLoc
                      callBack:(LoginCallBack)callBack
{
    _isLogin = 1;
    
    NSString *_pwd = @"";
    
    
    if (![@"3" isEqualToString:userLoc]) {
        
        //匹配6-15个由字母/数字组成的字符串的正则表达式：
        NSString *_phoneNumRegex = @"1[0-9]{10}";
        //匹配邮箱格式
        NSString *_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        
        
        NSPredicate *_pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _phoneNumRegex];
        
        if (![_pred evaluateWithObject:loginName]) {
            _pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _emailRegex];
            
            if (![_pred evaluateWithObject:loginName]) {
                
                if (callBack) {
                    callBack(REQUEST_FAILURE_CODE, @"用户名必须为邮箱或手机号码", @"用户名必须为邮箱或手机号码");
                }
                
                return;
            }
            
        }
        
        
        if (isEncrypt) {
            _pwd = loginPwd;
        }
        else{
            if (loginPwd && loginPwd.length >= 6 && loginPwd.length < 16 ) {
                _pwd = [NSString encrypt:[self inputStr:loginPwd]];
            }else{
                if (callBack)
                {
                    callBack(REQUEST_FAILURE_CODE, @"密码长度应为6～15位", @"密码长度应为6～15位");
                }
                
                return;
            }
            
        }

    }
    else{
        _pwd = [self inputStr:loginPwd];;
    }
    
    
    _loginCallBack = callBack;
    [_userInfomationModel requestLoginWithloginName:[self inputStr:loginName]
                                           loginPwd:[self inputStr:_pwd]
                                           userInfo:@{@"loc":[self inputStr:userLoc] }];
}

- (void)getCheckCodeWithLoginName:(NSString *)loginName
                        validType:(ValidCodeType)validType
                         callBack:(GetCheckCodeCallBack)callBack
{

    //匹配6-15个由字母/数字组成的字符串的正则表达式：
    NSString *_phoneNumRegex = @"1[0-9]{10}";
    //匹配邮箱格式
    NSString *_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _phoneNumRegex];
    
    if (![_pred evaluateWithObject:loginName]) {
        _pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _emailRegex];
        
        if (![_pred evaluateWithObject:loginName]) {
            if (callBack) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callBack(REQUEST_FAILURE_CODE,  @"用户名必须为邮箱或手机号码");
                });
                
            }
            
            return;
        }
        
    }
    
    

    
    
    _getCheckCodeCallBack = callBack;
    [_userInfomationModel requestSendValidCodeWithloginName:[self inputStr:loginName]
                                                  validType:[self inputStr:[NSString stringWithFormat:@"%d",
                                                                            (int)validType]]];
}


/*  注册用户信息  */
- (void)userRegisterWithUser:(UserInfoEntity *)user
                   validCode:(NSString *)validCode
                    callBack:(RegisterCallBack)callBack
{
    //匹配6-15个由字母/数字组成的字符串的正则表达式：
    NSString *_phoneNumRegex = @"1[0-9]{10}";
    //匹配邮箱格式
    NSString *_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _phoneNumRegex];
    
    if (![_pred evaluateWithObject:user.UI_loginName]) {
        
        _pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _emailRegex];
        
        if (![_pred evaluateWithObject:user.UI_loginName]) {
            if (callBack) {
                callBack(REQUEST_FAILURE_CODE, nil, @"用户名必须为邮箱或手机号码");
            }
            
            return;
        }
        
    }
    if (user.UI_loginPwd && user.UI_loginPwd.length >= 6 && user.UI_loginPwd.length < 16 ) {
        
    }
    else{
        callBack(REQUEST_FAILURE_CODE, nil, @"密码长度应为6～15位");
        return;
    }
    
 
    
    _registerCallBack = callBack;
    
    float _h = [user.UI_height floatValue];;
    float _t = 0;
    if ([user.UI_sex intValue]) {
        _t = (_h - 80) * 0.7;
    }
    else{
        _t = (_h - 70) * 0.6;
    }
    
    
    if (user.UI_lastUserData) {
        
        user.UI_lastUserData.UD_ID      = @"-999";
        user.UI_lastUserData.UD_userId  = @"-999";
        user.UI_lastUserData.UD_MEMID   = @"-999";

        
    }
    
    NSString *_modeStr      = [self inputStr:user.UI_mode];
    NSString *_planStr      = [self inputStr:user.UI_plan];
    NSString *_privacyStr   = [self inputStr:user.UI_privacy];
    
    
    user.UI_nickname = [self inputStr:user.UI_loginName];
    
    [_userInfomationModel requestRegisterWithloginName:[self inputStr:user.UI_loginName]
                                              password:[self inputStr:user.UI_loginPwd]
                                              nickName:[self inputStr:user.UI_nickname]
                                                   sex:[self inputStr:user.UI_sex]
                                                weight:[self inputStr:user.UI_lastUserData.UD_WEIGHT]
                                                height:[self inputStr:user.UI_height]
                                                   age:[self inputStr:user.UI_birthday]
                                             validCode:[self inputStr:validCode]
                                                  mode:[_modeStr isEqualToString:@""]?@"1":_modeStr
                                                  plan:[_planStr isEqualToString:@""]?@"2":_planStr
                                                target:[self inputStr:[[NSNumber numberWithFloat:_t ] stringValue]]
                                               privacy:[_privacyStr isEqualToString:@""]?@"0":_privacyStr
                                                  data:user.UI_lastUserData];
}



- (NSArray *)getUserDataWithCallBack:(GetUserDataCallBack)callBack
{
    
    
    NSString *_dt   = @"";
    NSString *_bd   = @"";
    NSString *_ed   = @"";
    NSString *_uid  = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;

    NSArray *_dataAry = [[DatabaseService defaultDatabaseService] getUserDataByUid:_uid];
    
    
    NSDate *_dateNow = [NSDate date];
    _dt     = @"5";
    _ed     = [Helpers getDateStr:_dateNow];
    
    
    
    
    if (_dataAry.count > 0) {
        
        UserDataEntity *_ud = _dataAry[0];
        _bd = [Helpers getDateStrFromDate:[Helpers getDateByString:_ud.UD_CHECKDATE]
                                bySeconds: 1] ;
        
 
    }else{
       
        _bd = [Helpers getDateStrFromDate:_dateNow bySeconds:-3600 * 24 * 365];
        
    }
    
    if (![GloubleProperty sharedInstance].sessionId) {
        if (callBack) {
            callBack(REQUEST_FAILURE_CODE, @{@"errorMsg":@"sessionId不能为空"},@"sessionId不能为空");
        }
        return _dataAry;
    }

    _getUserDataCallBack = callBack;
    [_userDataModel requestQueryMeasurementDataWithsessionId:[self inputStr:[GloubleProperty sharedInstance].sessionId]
                                                      userId:[self inputStr:_uid]
                                                    dateType:[self inputStr:_dt]
                                                   beginDate:[self inputStr:_bd]
                                                     endDate:[self inputStr:_ed] ];
    
    UserDataEntity *_lastUd = [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
    if (_lastUd) {
        
        [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
        [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
    }
    
    return _dataAry;
    
}

/**
 *  从请求当前用户数据
 *
 *  @param callBack
 */
- (void)getUserDataWithCallBack2:(GetUserDataCallBack)callBack{
    
    
    NSString *_dt   = @"";
    NSString *_bd   = @"";
    NSString *_ed   = @"";
    NSString *_uid  = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;
    
    NSArray *_dataAry = [[DatabaseService defaultDatabaseService] getLastUserDataListByUid:_uid num:1];
    
    
    NSDate *_dateNow = [NSDate date];
    _dt     = @"5";
    _ed     = [Helpers getDateStr:_dateNow];
    
    
    
    
    if (_dataAry.count > 0) {
        
        UserDataEntity *_ud = _dataAry[0];
        _bd = [Helpers getDateStrFromDate:[Helpers getDateByString:_ud.UD_CHECKDATE]
                                bySeconds: 1] ;
        
        
    }else{
        
        _bd = [Helpers getDateStrFromDate:_dateNow bySeconds:-3600 * 24 * 365];
        
    }
    
    if (![GloubleProperty sharedInstance].sessionId) {
        if (callBack) {
            callBack(REQUEST_FAILURE_CODE, @{@"errorMsg":@"sessionId不能为空"},@"sessionId不能为空");
        }
        
    }
    
    _getUserDataCallBack = callBack;
    [_userDataModel requestQueryMeasurementDataWithsessionId:[self inputStr:[GloubleProperty sharedInstance].sessionId]
                                                      userId:[self inputStr:_uid]
                                                    dateType:[self inputStr:_dt]
                                                   beginDate:[self inputStr:_bd]
                                                     endDate:[self inputStr:_ed] ];
    
    UserDataEntity *_lastUd = [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
    if (_lastUd) {
        
        [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
        [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
    }
    

    
}

- (void)updateUserInfoWithCallBack:(UpdateUserInfoCallBack)callBack
{

    _updateUserInfoWithCallBack = callBack;
    
    GloubleProperty *_gp        = [GloubleProperty sharedInstance];
    UserInfoEntity *_uie        = _gp.currentUserEntity;
    
    
    int _nowYear = 0;
    if (![@"" isEqualToString:[self inputStr:_uie.UI_birthday]]) {
        NSArray *_bAry = [_uie.UI_birthday componentsSeparatedByString:@"-"];
        if (_bAry.count == 3) {
            _nowYear = [(NSString *)_bAry[0] integerValue];
        }
    }
    
    int _age    = [Helpers getNowYear] - _nowYear;
    _uie.UI_age = [NSString stringWithFormat:@"%d",_age];
    
    
    [_userInfomationModel requestUpdateUserInformationWithsessionId:[self inputStr:_gp.sessionId]
                                                            loginId:nil
                                                           passWord:nil
                                                          validCode:nil
                                                                age:[self inputStr:_uie.UI_birthday]
                                                           nickname:[self inputStr:_uie.UI_nickname]
                                                            chnName:[self inputStr:_uie.UI_cname]
                                                                sex:[self inputStr:_uie.UI_sex]
                                                     homeProvinceId:nil
                                                   homeProvinceName:nil
                                                         homeCityId:nil
                                                       homeCityname:nil
                                                         homeAreaId:nil
                                                       homeAreaName:nil
                                                     locaProvinceId:nil
                                                   locaProvinceName:nil
                                                         locaCityId:nil
                                                       locaCityName:nil
                                                         locaAreaId:nil
                                                       locaAreaName:nil
                                                          photoPath:[self inputStr:_uie.UI_photoPath]
                                                           birthday:nil
                                                             height:[self inputStr:_uie.UI_height]
                                                             weight:[self inputStr:_uie.UI_weight]
                                                         profession:nil
                                                       privacyLevel:[self inputStr:_uie.UI_privacy]
                                                           authBind:nil
                                                             status:nil
                                                             remark:nil
                                                          regStatus:nil
                                                       bodyscaleLoc:nil];
    
}

- (void)updateUserSettingWithCallBack:(UpdateUserSettingCallBack)callBack
{
    _updateUserSettingCallBack  = callBack;
    GloubleProperty *_gp        = [GloubleProperty sharedInstance];
    UserInfoEntity *_uie        = _gp.currentUserEntity;
    
    [_userDataModel requestSettingWithsessionId:[self inputStr:_gp.sessionId]
                                         userId:[self inputStr:_uie.UI_userId]
                                           mode:[self inputStr:_uie.UI_mode]
                                           plan:[self inputStr:_uie.UI_plan]
                                         target:[self inputStr:_uie.UI_target]
                                        privacy:[self inputStr:_uie.UI_privacy]
                                    remindcycle:[self inputStr:_uie.UI_remindcycle]
                                     remindmode:[self inputStr:_uie.UI_remindmode]  ];
}

-(void)getUserSettingWithCallBack:(WebCallBack)callback
{
    GloubleProperty *_gp        = [GloubleProperty sharedInstance];
    _getUserSettingCallBack     = callback;
    if (_gp.currentUserEntity) {
        [_userDataModel requestQuerySettingWithsessionId:[self inputStr:_gp.sessionId]
                                                  userId:[self inputStr:_gp.currentUserEntity.UI_userId]];
    }
    
}

- (void)upLoadImage:(UIImage *)img
       WithCallBack:(UpLoadImageCallBack)callBack;
{
    _upLoadImageCallBack  = callBack;


    NSString *_fn = [NSString stringWithFormat:@"%@",[GloubleProperty sharedInstance].currentUserEntity.UI_userId];

    [_userInfomationModel requestUploadFileWithfileName:[self inputStr:_fn]
                                                   data:UIImageJPEGRepresentation(img, 0.5)];
    
}

- (void)userLogoutWithCallBack:(UserLogoutCallBack)callBack
{
    
    _loginState = 0;
    
    _loginDate = nil;
    
    [GloubleProperty sharedInstance].currentUserEntity  = nil;
    [GloubleProperty sharedInstance].sessionId          = nil;
    
    NSUserDefaults *_udf = [NSUserDefaults standardUserDefaults];
    
    [_udf removeObjectForKey:@"userId"];
    [_udf removeObjectForKey:@"sessionId"];
    [_udf synchronize];
    
    if (callBack) {
        //_userLogoutCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
        callBack(REQUEST_SUCCESS_CODE,@"",@"");
    }
    
    /*
    _userLogoutCallBack = callBack;
    [_userInfomationModel requestLogoutWithsessionId: [self inputStr:[GloubleProperty sharedInstance].sessionId] ];
     */
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int _tag        = (int)alertView.tag ;
    switch (_tag) {
        case 101:
        {
            switch (buttonIndex) {
                case 1:
                {
                    if (_checkDataDic) {

                        [self submitUserData:_checkDataDic[@"data"]
                                    deviceNo:_checkDataDic[@"deviceNo"]
                                        flag:YES
                                WithCallBack:_checkDataDic[@"callBack"]];
                        [_checkDataDic removeAllObjects];
                        _checkDataDic = nil;
                    }
                    _checkDataAlt = nil;

                }
                    break;
                    
                default:
                {
                    if (_checkDataDic) {
                        [_checkDataDic removeAllObjects];
                        _checkDataDic = nil;
                    }
                    _checkDataAlt = nil;
                }
                    break;
            }
        }
            break;
        default:
            break;
    }
}

- (void)submitUserData:(UserDataEntity *)data
              deviceNo:(NSString *)devNo
                  flag:(BOOL)isChecked
          WithCallBack:(SubmitUserDataCallBack)callBack
{
    
    if (!data || !data.UD_location) {
        if (callBack) {
            callBack(REQUEST_FAILURE_CODE,nil, @"数据或坑位号不能为空");
        }
        return;
    }
    

    
    if (_checkDataAlt) {
        
        [_checkDataDic removeAllObjects];
        _checkDataDic = nil;
        
    }
    
    if (!isChecked) {
        if (![self checkData:data]) {

            if (callBack) {
                if (devNo) {
                    _checkDataDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"data":data,
                                                                                    @"deviceNo":devNo,
                                                                                    @"callBack":callBack }];
                }
                else{
                    _checkDataDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"data":data,
                                                                                    @"callBack":callBack }];
                
                }
            }
            else{
                if (devNo) {
                    _checkDataDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"data":data,
                                                                                    @"deviceNo":devNo }];
                }
                else{
                    _checkDataDic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"data":data}];
                    
                }
            }
            
            
            if (!_checkDataAlt) {
                _checkDataAlt = [[UIAlertView alloc]initWithTitle:@"提 示"
                                                              message:@"本次检测数据对应上一次数据与异常，是否要保存此次数据？"
                                                             delegate:self
                                                    cancelButtonTitle:@"不保存"
                                                    otherButtonTitles:@"保 存",nil];
                _checkDataAlt.tag = 101;
                [_checkDataAlt show];
            }

            return;
        }
    }
    
    
    if (_checkDataAlt) {
        [_checkDataAlt dismissWithClickedButtonIndex:0 animated:YES];
        _checkDataAlt = nil;
    }
    
    _submitUserDataCallBack = callBack;
    
    data.UD_ID      = @"-101";
    data.UD_devcode = [self inputStr:devNo];
    data.UD_userId  = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;
    data.UD_MEMID   = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;
    

    if ([[DatabaseService defaultDatabaseService]saveSingleUserData:data]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataChanged
                                                           object:nil
                                                         userInfo:nil];
    }

    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    [_userDataModel requestSubmitMeasurementDataWithsessionId:[self inputStr:_ssid]
                                                       userId:[self inputStr:data.UD_userId]
                                                       weight:[[self inputStr:data.UD_WEIGHT] floatValue]
                                                          bmi:[[self inputStr:data.UD_BMI] floatValue]
                                                          fat:[[self inputStr:data.UD_FAT] floatValue]
                                                      skinfat:[[self inputStr:data.UD_SKINFAT] floatValue]
                                                     offalfat:[[self inputStr:data.UD_OFFALFAT] floatValue]
                                                       muscle:[[self inputStr:data.UD_MUSCLE] floatValue]
                                                   metabolism:[[self inputStr:data.UD_METABOLISM] floatValue]
                                                        water:[[self inputStr:data.UD_WATER] floatValue]
                                                         bone:[[self inputStr:data.UD_BONE] floatValue]
                                                      bodyage:[[self inputStr:data.UD_BODYAGE] floatValue]
                                                       longit:[self inputStr:data.UD_longit]
                                                        latit:[self inputStr:data.UD_latit]
                                                      devcode:[self inputStr:data.UD_devcode]
                                                     location:[self inputStr:data.UD_location]
                                                    checkdate:[self inputStr:data.UD_CHECKDATE] ];
    
    JDDataEntity *_jdD = [JDPlusModel transDataToJDData:data];
    if (_jdD) {
        /*
        UserInfoEntity *_gp = [GloubleProperty sharedInstance].currentUserEntity;
        if (_gp) {
            _jdD.jdd_age = [self inputStr:_gp.UI_age];
        }
        
         */
        [self jingDongUpload:_jdD
                    callback:^(int code, id successParam, id errorMsg) {
                        
                    }];
    }
    
 
    
}






/* 提交建议 */
-(void)submitSuggest:(NSString *)content
        WithCallBack:(SubmitSuggestCallBack)callBack
{
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    if (!_ssid || [@"" isEqualToString:_ssid]) {
        if (callBack) {
            callBack(REQUEST_FAILURE_CODE,nil, @"会话超时");
        }
        
        return;
    }
    _submitSuggestCallBack = callBack;
    [_userDataModel requestSubmitSuggestWithsessionId:[self inputStr:_ssid]
                                              content:[self inputStr:content]];
}

-(void)querySuggestWithCallBack:(QuerySuggestCallBack)callBack
{
    _querySuggestCallBack = callBack;

    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    NSString *_uid  = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;
    
    [_userDataModel requestQuerySuggestWithsessionId:[self inputStr:_ssid]
                                              userId:[self inputStr:_uid]
                                            userInfo:@"0"] ;
}

/* 查询时间提示信息 */
-(void)queryNoticeWithCallBack:(WebCallBack)callBack
{
    
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    if (!_ssid || [@"" isEqualToString:_ssid]) {
        if (callBack) {
            callBack(REQUEST_FAILURE_CODE,nil, @"会话超时");
        }
        return;
    }
    
    _queryNoticeCallBack = callBack;
    [_userInfomationModel requestQueryNoticeWithsessionId:[self inputStr:_ssid]
                                                 userInfo:@0];
    
    
}

-(void)changePasswordWithOld:(NSString *)oldPWD
                         new:(NSString *)newPWD
                    callBack:(WebCallBack)callBack
{
    
    if (newPWD && newPWD.length >= 6 && newPWD.length < 16 ) {
        
    }else{
        callBack(REQUEST_FAILURE_CODE, @"密码长度应为6～15位", @"密码长度应为6～15位");
        return;
    }
    
    _requestChangePWDCallBack = callBack;
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    
    [_userDataModel requestModifyPasswordWithSessionId:[self inputStr:_ssid]
                                          userPassword:[self inputStr:oldPWD]
                                           newPassword:[self inputStr:newPWD] ];
}
/* 重置密码  */
-(void)resetPasswordWithLonginName:(NSString *)longinName
                         validCode:(NSString *)validCode
                            newPwd:(NSString *)newPwd
                          callBack:(WebCallBack)callBack
{
    
    //匹配6-15个由字母/数字组成的字符串的正则表达式：
    NSString *_phoneNumRegex = @"1[0-9]{10}";
    //匹配邮箱格式
    NSString *_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _phoneNumRegex];
    
    if (![_pred evaluateWithObject:longinName]) {
        _pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _emailRegex];
        
        if (![_pred evaluateWithObject:longinName]) {
            callBack(REQUEST_FAILURE_CODE, @"用户名必须为邮箱或手机号码", @"用户名必须为邮箱或手机号码");
            return;
        }
        
    }
    
    
    
    
    if (newPwd && newPwd.length >= 6 && newPwd.length < 16 ) {
        
    }else{
        callBack(REQUEST_FAILURE_CODE, @{@"errorMsg":@"密码长度应为6～15位"}, @"密码长度应为6～15位");
        return;
    }
    
    
    _requestResetPWDCallBack = callBack;
    [_userInfomationModel requestResetPWDWithloginName:[self inputStr:longinName]
                                             validCode:[self inputStr:validCode]
                                                newPwd:[self inputStr:newPwd] ];
}

/* 请求机器唯一码  */
-(void)getSoleDeviceCodeWithCallBack:(WebCallBack)callBack
{
    _getSoleDeviceCodeCallBack = callBack;
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    [_userDataModel requestQueryDevCodeWithsessionId:[self inputStr:_ssid] ] ;
}

/* 绑定设备码  */
-(void)submitBindWithDevCode:(NSString *)devCode
                    location:(NSString *)location
                    callBack:(WebCallBack)callBack
{
    if (![GloubleProperty sharedInstance].sessionId ||
        ![GloubleProperty sharedInstance].currentUserEntity
    ) {

        if (callBack) {
            callBack(REQUEST_FAILURE_CODE,@{@"errorMsg":@"ssid为nil"},@"ssid为nil");
        }

        return;
    }
    _submitBindCallBack = callBack;
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    
    [_userDataModel requestSubmitBindWithsessionId:[self inputStr:_ssid]
                                           devCode:[self inputStr:devCode]
                                          location:[self inputStr:location] ];
}

/* 解除绑定设备码  */
-(void)cancelBindWithDevCode:(NSString *)devCode
                      bindId:(NSString *)bindId
                    callBack:(WebCallBack)callBack
{
    _cancelBindCallBack = callBack;
    
    
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    
    [_userDataModel requestCancelBindWithsessionId:[self inputStr:_ssid]
                                           devCode:[self inputStr:devCode]
                                            bindId:bindId ];
    
}

/* 提交批量数据  */
-(void)submitBatchDataWithDataList:(NSArray *)dataList
                           devCode:(NSString *)devCode
                          callBack:(WebCallBack)callBack
{
    if (![GloubleProperty sharedInstance].sessionId ||
        ![GloubleProperty sharedInstance].currentUserEntity
    ) {
        return;
    }
    
    
    _submitBatchDataCallBack = callBack;
    
    
    /* 创建 总数据数组容器 */
    NSMutableArray *_tempDataList = nil;
    if (dataList) {
        _tempDataList = [[NSMutableArray alloc]initWithArray:dataList];
    }
    else{
        _tempDataList = [[NSMutableArray alloc]init];
    }
    
    
    /* 将本地未提交成功数据放入 总数据数组容器 */
    NSArray *_dataListForApp = [[DatabaseService defaultDatabaseService]
                                getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId
                                dataId:@"-101"];
    if (_dataListForApp) {
        for (int i = 0; i < _dataListForApp.count; i++) {
            [_tempDataList addObject:_dataListForApp[i]];
        }
    }
    
    /* 将本地未提交成功批量数据放入 总数据数组容器 */
    NSArray *_dataListForApp02 = [[DatabaseService defaultDatabaseService]
                                getUserDataByDataId:@"-1010"];
    if (_dataListForApp02) {
        for (int i = 0; i < _dataListForApp02.count; i++) {
            [_tempDataList addObject:_dataListForApp[i]];
        }
    }
    
    /* 装填网络发送字典  同时  装填暂时保存数据  */
    NSMutableArray *_datalist       = [[NSMutableArray alloc]init];
    NSMutableArray *_dataSaveList   = [[NSMutableArray alloc]init];

    for (int i = 0 ; i < _tempDataList.count; i++) {
        if (_tempDataList[i] &&
            [_tempDataList[i] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *_locDic = _tempDataList[i];
            NSArray *_udAry = _locDic[@"dataList"];
            NSString *_loc  = _locDic[@"location"];
            
            
            if (_udAry && [_udAry isKindOfClass:[NSArray class]])
            {
                for (int j = 0; j <_udAry.count; j++) {
                    UserDataEntity *_ud = _udAry[j];
                    if (_ud) {
                        _ud.UD_ID = @"-1010";
                        [_dataSaveList addObject:_ud];
                        
                        [_datalist addObject:@{
                                               @"userId":[self inputStr:_ud.UD_userId],
                                               
                                               @"weight":[self inputStr:_ud.UD_WEIGHT],
                                               @"bmi":[self inputStr:_ud.UD_BMI],
                                               @"fat":[self inputStr:_ud.UD_FAT],
                                               @"skinfat":[self inputStr:_ud.UD_SKINFAT],
                                               
                                               @"offalfat":[self inputStr:_ud.UD_OFFALFAT],
                                               @"muscle":[self inputStr:_ud.UD_MUSCLE],
                                               @"metabolism":[self inputStr:_ud.UD_METABOLISM],
                                               @"water":[self inputStr:_ud.UD_WATER],
                                               
                                               @"bone":[self inputStr:_ud.UD_BONE],
                                               @"bodyage":[self inputStr:_ud.UD_BODYAGE],
                                               @"longit":[self inputStr:_ud.UD_longit],
                                               @"latit":[self inputStr:_ud.UD_latit],
                                               
                                               @"devcode":[self inputStr:devCode],
                                               @"location":[self inputStr:_loc],
                                               @"status":@"0",
                                               @"checkdate":[self inputStr:_ud.UD_CHECKDATE],
                                               }];
                    }
                }
            }
        }
        else
        {
            UserDataEntity *_ud = _tempDataList[i];
            if (_ud) {
                [_datalist addObject:@{
                                       @"userId":[self inputStr:_ud.UD_userId],
                                       
                                       @"weight":[self inputStr:_ud.UD_WEIGHT],
                                       @"bmi":[self inputStr:_ud.UD_BMI],
                                       @"fat":[self inputStr:_ud.UD_FAT],
                                       @"skinfat":[self inputStr:_ud.UD_SKINFAT],
                                       
                                       @"offalfat":[self inputStr:_ud.UD_OFFALFAT],
                                       @"muscle":[self inputStr:_ud.UD_MUSCLE],
                                       @"metabolism":[self inputStr:_ud.UD_METABOLISM],
                                       @"water":[self inputStr:_ud.UD_WATER],
                                       
                                       @"bone":[self inputStr:_ud.UD_BONE],
                                       @"bodyage":[self inputStr:_ud.UD_BODYAGE],
                                       @"longit":[self inputStr:_ud.UD_longit],
                                       @"latit":[self inputStr:_ud.UD_latit],
                                       
                                       @"devcode":[self inputStr:devCode],
                                       @"location":[self inputStr:_ud.UD_location],
                                       @"status":[self inputStr:_ud.UD_STATUS],
                                       @"checkdate":[self inputStr:_ud.UD_CHECKDATE],
                                       }];
            }
        }
    }

    /* 保存批量数据 */
    [[DatabaseService defaultDatabaseService]saveUserData:_dataSaveList];
    
    
    
    /* 提交服务器 */
    if (_datalist.count > 0) {
        NSDictionary *_jData = @{@"dataList":_datalist};
        
        NSData *_jsonData = [NSJSONSerialization dataWithJSONObject:_jData
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:nil];
        NSString *_jStr = [[NSString alloc] initWithData:_jsonData
                                                encoding:NSUTF8StringEncoding];

        NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
        
        [_userDataModel requestSubmitBatchDataWithsessionId:[self inputStr:_ssid]
                                                   jsonData:_jStr
                                                       list:nil];
    }
    else{
        if (_submitBatchDataCallBack) {
            _submitBatchDataCallBack(REQUEST_SUCCESS_CODE, @"无需要批量提交数据",nil);
        }
        
    }
    
    
    
}




/**
 *  提交赞 ，激励 ，提醒称重
 *
 *  @param tUid     目标用户uid
 *  @param tp       1：赞 ，2：激励 3:提醒称重
 *  @param callBack 操作结果回调
 */
-(void)submitPraiseWithTargetUid:(NSString *)tUid
                            type:(PraiseType)tp
                        callBack:(WebRequestCallBack)callBack
{
    NSString *_uid  = [self inputStr:tUid];
    NSString *_tp   = @"";
    //NSString *_utp  = @"";
    
    switch (tp) {
        case PraiseType_praise:
        {
            _tp = @"1";
        }
            break;
        case PraiseType_excitation:
        {
            _tp = @"2";
        }
            break;
        case PraiseType_remind:
        {
            _tp = @"3";
        }
            break;
        default:
            break;
    }
    
    NSString *_ssid = [self inputStr:[GloubleProperty sharedInstance].sessionId];
    
    if ([_ssid isEqualToString:@""]) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话Id不能为空"];

        return;
    }
    
    if ([_uid isEqualToString:@""]) {
        
        [self fillWebErrorParam:callBack errorObj:@"用户Id不能为空"];
        
        return;
    }
    
    if ([_tp isEqualToString:@""]) {
        
        [self fillWebErrorParam:callBack errorObj:@"类型不能为空"];

        return;
    }
    
    _submitPraiseCallBack = callBack;
    [_userDataModel requestSubmitPraiseWithsessionId:_ssid
                                              userId:_uid
                                                type:_tp];
}


/**
 *  66.	查询 赞/激励/提醒 用户列表
 *
 *  @param uid     目标用户uid
 *  @param tp       1：赞 ，2：激励 3:提醒称重
 *  @param callBack 操作结果回调
 */
-(NSArray *)queryPraiseWithTargetUid:(NSString *)uid
                                type:(PraiseType)tp
                            callBack:(WebRequestCallBack)callBack
{
    NSArray *_request = nil;//[[DatabaseService defaultDatabaseService] ];
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    NSString *_uid  = [self inputStr:uid];
    NSString *_ssid = [self inputStr:_gp.sessionId];
    NSString *_tp   = @"";
    
    switch (tp) {
        case PraiseType_praise:
        {
            _tp = @"1";
        }
            break;
        case PraiseType_excitation:
        {
            _tp = @"2";
        }
            break;
        case PraiseType_remind:
        {
            _tp = @"3";
        }
            break;
        default:
            break;
    }

    if ([_ssid isEqualToString:@""]) {

        [self fillWebErrorParam:callBack errorObj:@"会话Id不能为空"];
        
        return _request;
    }
    
    if ([_uid isEqualToString:@""]) {
        
        if (_gp.currentUserEntity) {
            
            _uid = [self inputStr:_gp.currentUserEntity.UI_userId];
            
        }
        else{
            
            [self fillWebErrorParam:callBack errorObj:@"用户id不能为空"];
            return _request;
        }
    }
    
    if ([_tp isEqualToString:@""]) {
        
        [self fillWebErrorParam:callBack errorObj:@"类型不能为空"];
        return _request;
    }
    
    
    
    _queryPraiseCallBack = callBack;
    [_userDataModel requestQueryPraiseWithsessionId:_ssid
                                             userId:_uid
                                               type:_tp];
    
    return nil;
    
}


/**
 *  查询好友列表
 *
 *  @param uid      用户uid
 *  @param callBack FriendInfoEntity列表
 */
-(NSArray *)queryFriendListWithUserId:(NSString *)uid
                             CallBack:(WebRequestCallBack)callBack
{
    NSArray *_request = [[DatabaseService defaultDatabaseService]
                                    getUserFriendList:[self inputStr:uid]];

    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId ){
    
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];

        return _request;
    }
    if (!uid) {
        
        [self fillWebErrorParam:callBack errorObj:@"用户id不能为空"];

        return _request;
    }
    
    _queryFriendCallBack = callBack;
    [_userDataModel requestQueryFocusDataWithsessionId:[self inputStr:_gp.sessionId]
                                                userId:[self inputStr:uid]
                                              userInfo:@"F"];
    
    return _request;
    
}

/**
 *  查询好友列表
 *
 *  @param uid      用户uid
 *  @param callBack result操作结果, successParam 操作成功为FriendInfoEntity列表, errorMsg操作失败信息字符串
 */
-(void)queryARFriendListWithUserId:(NSString *)uid
                          callBack:(WebRequestCallBack)callBack
{
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId ){
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    if (!uid) {
        
        [self fillWebErrorParam:callBack errorObj:@"用户id不能为空"];
        
        return;
    }
    
    _queryARFriendCallBack = callBack;
    [_userDataModel requestQueryFocusDataWithsessionId:[self inputStr:_gp.sessionId]
                                                userId:[self inputStr:uid]
                                              userInfo:@"ARF"];
    
    
    
}







/**
 *  添加关注根据用户名
 *
 *  @param flName 用户登录名
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)addFriendWithFriendLonginName:(NSString *)flName
                            callBack:(WebRequestCallBack)callBack
{
    //匹配6-15个由字母/数字组成的字符串的正则表达式：
    NSString *_phoneNumRegex = @"1[0-9]{10}";
    //匹配邮箱格式
    NSString *_emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    
    NSPredicate *_pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _phoneNumRegex];
    
    if (![_pred evaluateWithObject:flName]) {
        _pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _emailRegex];
        
        if (![_pred evaluateWithObject:flName]) {
            
            [self fillWebErrorParam:callBack errorObj:@"用户名必须为邮箱或手机号码"];
            
            return;
        }
        
    }
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (_gp.sessionId && _gp.currentUserEntity) {
        
        
        int _pNum = [[self inputStr:_gp.currentUserEntity.UI_privacy] intValue];
        
        _addFriendWithFriendLonginNameCallBack = callBack;
        [_userInfomationModel requestAddFocusWithSessionId:[self inputStr:_gp.sessionId]
                                               focusUserId:nil
                                            focusLoginName:flName
                                                    mRight:[NSNumber numberWithInt:_pNum]
                                             specFocusFlag:@0
                                                   appType:@2];
    }else{
        
        [self fillWebErrorParam:callBack errorObj:@"用户未登录"];
        
        return;
    }
    
    
    
}

/**
 *  添加关注根据用户id
 *
 *  @param uid      用户id
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)addFriendWithFriendUid:(NSString *)uid
                     callBack:(WebRequestCallBack)callBack
{
    if (!uid) {
        [self fillWebErrorParam:callBack errorObj:@"用户id为空"];
    }
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (_gp.sessionId && _gp.currentUserEntity) {
        
        
        int _pNum = [[self inputStr:_gp.currentUserEntity.UI_privacy] intValue];
        
        _addFriendWithFriendLonginNameCallBack = callBack;
        [_userInfomationModel requestAddFocusWithSessionId:[self inputStr:_gp.sessionId]
                                               focusUserId:[NSNumber numberWithInt:[ [self inputStr: uid ] intValue]]
                                            focusLoginName:nil
                                                    mRight:[NSNumber numberWithInt:_pNum]
                                             specFocusFlag:@0
                                                   appType:@2];
    }else{
        
        [self fillWebErrorParam:callBack errorObj:@"用户未登录"];
        
        return;
    }
    
    
    
}


/**
 *  修改好友权限
 *
 *  @param fEntity 好友对象
 *  @param mRight  对方权限 0:无权限;1:查看;2:编辑
 */
-(void)modifyFriendRightWithFriend:(FriendInfoEntity *)fEntity
                            mright:(FriendMRightType)mRight
                          callBack:(WebRequestCallBack)callBack
{

    NSString *_ssid = nil;
    NSNumber *_mId  = nil;
    NSNumber *_mR   = nil;
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    
    if (!fEntity) {
        
        [self fillWebErrorParam:callBack errorObj:@"请选择好友"];
        
        return;
    }
    else{
        if (!fEntity.FI_mid) {
            
            [self fillWebErrorParam:callBack errorObj:@"好友id不能为空"];
            
            return;
        }
        else{
            _mId = [NSNumber numberWithInt:[[self inputStr:fEntity.FI_mid] intValue]];
        }
    }
    
    switch (mRight) {
            case FriendMRightType_rejective:
            {
                _mR = @0;
            }
                break;
            case FriendMRightType_lookOver:
            {
                _mR = @1;
            }
                break;
            case FriendMRightType_edit:
            {
                _mR = @2;
            }
                break;
                
            default:
            {
                
                [self fillWebErrorParam:callBack errorObj:@"权限参数不正确"];
                callBack = nil;
                
                return;
            }
                break;
        }


    _modifyFriendRightCallBack = callBack;
    [_userInfomationModel requestMRightFocusWithSessionId:_ssid
                                                      mId:_mId
                                                   mRight:_mR
                                                  appType:@2];
}


/**
 *  删除好友
 *
 *  @param fEntity  好友对象
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)deleteFriendWithFriend:(FriendInfoEntity *)fEntity
                     callBack:(WebRequestCallBack)callBack
{
    NSString *_ssid = nil;
    NSNumber *_mId  = nil;

    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    
    if (!fEntity) {
        
        [self fillWebErrorParam:callBack errorObj:@"请选择好友"];
        
        return;
    }
    else{
        if (!fEntity.FI_mid) {
            
            [self fillWebErrorParam:callBack errorObj:@"好友id不能为空"];
            
            return;
        }
        else{
            _mId = [NSNumber numberWithInt:[[self inputStr:fEntity.FI_mid] intValue]];
        }
    }

    _deleteFriendCallBack = callBack;
    
    [_userInfomationModel requestDeleteFocusWithSessionId:_ssid
                                                      mId:_mId];
}


/**
 *  获取新消息
 *
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)getMSGWithCallback:(WebRequestCallBack)callBack
{
    NSString *_ssid     = nil;
    NSNumber *_foucsMe  = @1;
    
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        return;
    }else
    {
        _ssid = [self inputStr:_gp.sessionId];
    }
    _getMSGCallBack = callBack;
    
    [_userInfomationModel requestMyMsgCountsWithSessionId:_ssid
                                                  foucsMe:_foucsMe];
}


/**
 *  同意或拒绝 关注操作
 *
 *  @param fType    FocusType FocusType_ageree 同意，FocusType_refuse 拒绝
 *  @param mid      关注人的mid
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)focusSetWithSetTp:(FocusType)fType
                     mid:(NSString *)mid
                callback:(WebRequestCallBack)callBack
{

    NSString *_ssid = nil;
    NSNumber *_mId  = nil;
    NSNumber *_mR   = nil;
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    
    if (!mid) {
        
        [self fillWebErrorParam:callBack errorObj:@"好友id不能为空"];
        
        return;
    }
    else{
        _mId = [NSNumber numberWithInt:[[self inputStr:mid] intValue]];
    }
    
    switch (fType) {
        case FocusType_ageree:
        {
            _mR = @0;
        }
            break;
        case FocusType_refuse:
        {
            _mR = @1;
        }
            break;
        default:
        {
            
            [self fillWebErrorParam:callBack errorObj:@"操作参数不正确"];
            return;
        }
            break;
    }
    
    
    _focusSetCallBack = callBack;
    [_userInfomationModel requestAgreeFocusWithSessionId:_ssid
                                                     mId:_mId
                                                 appType:@2
                                                  stutas:_mR ] ;
    
}


/**
 *  关注我的用户列表
 *
 *  @param callBack result操作结果, successParam 操作成功返回MSGFocusMeEntity类型数组, errorMsg操作失败信息字符串
 */
-(void)getFocusMeListWithCallBack:(WebRequestCallBack)callBack
{
    NSString *_ssid = nil;

    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    

    
    
    _getFocusMeListCallBack = callBack;
    [_userInfomationModel requestFocusMeListWithSessionId:_ssid appType:@2 ] ;
    
}


/**
 *  将当前用户 未读消息设置为已读
 *
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)setMsgReadedWithCallBack:(WebRequestCallBack)callBack
{
    NSString *_ssid = nil;
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    
    
    
    
    _setMsgReadedCallBack = callBack;
    [_userInfomationModel requestFocusMeSetReadWithSessionId:_ssid
                                                         mId:nil] ;
    
}


/**
 *  删除关注消息
 *
 *  @param mid      消息对象MSGFocusMeEntity msgFm_mId 属性
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)delMsgWithMid:(NSString *)mid
            callBack:(WebRequestCallBack)callBack
{
    NSString *_ssid = nil;
    NSNumber *_mid = nil;
    
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];
    
    if (!_gp.sessionId) {
        
        [self fillWebErrorParam:callBack errorObj:@"会话id不能为空"];
        
        return;
    }
    else{
        _ssid = [self inputStr:_gp.sessionId];
    }
    
    if (!mid) {
        
        [self fillWebErrorParam:callBack errorObj:@"请选择要删除消息"];
        
        return;
    }
    else{
        _mid = [NSNumber numberWithInt:[[self inputStr:mid] intValue]] ;
    }
    
    
    
    
    _delMsgCallBack = callBack;
    [_userInfomationModel requestDelFocusMsgWithSessionId:_ssid mid:_mid] ;
    
}




-(void)queryNowNoticeWithCallBack:(QueryNowNoticeCallBack)callBack
{
    NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
    if (!_ssid || [@"" isEqualToString:_ssid]) {
        if (callBack) {
            callBack(NO,nil, @"会话超时");
        }
        
        return;
    }
    _queryNowNoticeCallBack = callBack;
    
    
    
    [_userInfomationModel requestQueryNoticeWithsessionId:[self inputStr:_ssid]
                                                 userInfo:@1];
    
    
}



/**
 *  删除单条数据
 *
 *  @param data 数据对象
 */
-(void)deleteDataWithData:(UserDataEntity *)data
                   reason:(DeleteDataReason)reason
                 callback:(WebRequestCallBack)callback
{
    if (data) {
        
        NSString *_ssid = [GloubleProperty sharedInstance].sessionId;
        if (!_ssid || [@"" isEqualToString:_ssid]) {
            if (callback) {
                [self fillWebErrorParam:callback errorObj:@"会话超时"];
            }
            return;
        }
        
        NSString *_dId      = data.UD_ID;
        NSNumber *_dNumId   = [NSNumber numberWithInt:[[self inputStr:_dId] intValue]];
        NSString *_reason   = @"3";
        switch (reason) {
            case DeleteDataReasonError:
            {
                _reason = @"1";
            }
                break;
            case DeleteDataReasonNotMy:
            {
                _reason = @"2";
            }
                break;
            case DeleteDataReasonJustDo:
            {
                _reason = @"3";
            }
                break;
            default:
                break;
        }
        _deleteDataCallback = callback;
        [_userDataModel requestDeleteDataWithsessionId:_ssid
                                                dataId:_dNumId
                                                reason:_reason
                                              userInfo:nil];
    }else{
    
        [self fillWebErrorParam:callback errorObj:@"无效数据"];
    }
    
    
    
}


/**
 *  验证 验证码是否有效
 *
 *  @param checkCode 验证码
 *  @param loginName 用户名
 *  @param callBack result操作结果, successParam 操作成功, errorMsg操作失败信息字符串
 */
-(void)checkCodeInvalidWithCheckCode:(NSString *)checkCode
                           loginName:(NSString *)loginName
                            callback:(WebRequestCallBack)callback
{
    NSString *_cc = [self inputStr:checkCode];
    NSString *_ln = [self inputStr:loginName];
    
    if ([@"" isEqualToString:_cc]) {
        [self fillWebErrorParam:callback errorObj:@"请输入验证码"];
        return;
    }
    
    if ([@"" isEqualToString:_ln]) {
        [self fillWebErrorParam:callback errorObj:@"请输入用户名"];
        return;
    }
    

    
    
    
    _checkCodeInvalidCallBack = callback;
    [_userDataModel requestCheckCodeInvalidWithLoginName:_ln
                                               checkCode:_cc
                                                userInfo:nil];
}


/**
 *  根据设备mac地址获取设备颜色
 *
 *  @param mac      设备mac地址
 *  @param callback callBack result操作结果, color 颜色枚举, errorMsg操作失败信息字符串
 */
-(void)getDevColorWithMac:(NSString *)mac
                 callback:(GetDevColorCallBack)callback
{
    if ([@"" isEqualToString:[self inputStr:mac]]) {
        if (callback) {
            callback(WebCallBackResultFailure,DevColorFaile,@"mac地址不能为空");
            return;
        }
    }

    _getDevColorCallback = callback;
    [_userDataModel requestGetDevColorWithMac:mac userInfo:nil];
}


-(void)checkLoginNameWithName:(NSString *)loginName
                     callback:(CheckLoginNameCallBack)callback
{
    _checkLoginNameCallBack = callback;
    [_userInfomationModel requestCheckLonginWithLoginName:loginName];
}


#pragma mark - 本地数据
/* 获取本机用户列表 */
- (NSArray *)getLocalUserList
{
    
    GloubleProperty *_gp = [GloubleProperty sharedInstance];

    return [[DatabaseService defaultDatabaseService] getLocalUserList:_gp.currentUserEntity.UI_userId];
    
}
/* 根据用户id查询用户信息*/
-(UserInfoEntity *)getUserByUid:(NSString *)uid
{
    return [[DatabaseService defaultDatabaseService] getUserByUid:uid];
}


-(NSArray *)getSuggestFromDB
{
    NSArray *_result = [[DatabaseService defaultDatabaseService]getSuggestListByUiduid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId];
    return _result;
}



/*  用户最后一次测量数据  */
-(UserDataEntity *)getLastDataByUser:(UserInfoEntity *)user
{
    NSArray *_ary = [[DatabaseService defaultDatabaseService] getLastUserDataListByUid:user.UI_userId
                                                                                   num:1];
    if (_ary && _ary.count > 0) {
        return _ary[0];
    }else{
        return nil;
    }
    
    
}

/**
 *  获取最后2条测量数据
 *
 *  @return UserDataEntity列表  长度最大为2，最小为0
 */
-(NSArray *)getLastTwoCheckData
{
    
    return [[DatabaseService defaultDatabaseService]
                    getLastUserDataListByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId
                                         num:2];
}









-(NSDictionary *)getUserDataByDay2:(NSDate *)targetDate
{
    NSDictionary *_dic = [[DatabaseService defaultDatabaseService]getDayDatasByDate:targetDate
                                                                       userDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId];
    /*
    NSMutableArray *_maxList    = _dic[kIMDateMaxListKey];
    NSMutableArray *_minList    = _dic[kIMDateMinListKey];

    
    [CalculateTool calculateFixMaxList:_maxList minList:_minList];
    */
    
    return _dic;
}

-(NSDictionary *)getUserDataByWeek2:(NSDate *)targetDate
{
    
    NSDictionary *_dic =
    [[DatabaseService defaultDatabaseService] getWeek:targetDate
                                         userDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId] ;
    /*
    NSMutableArray *_maxList = _dic[kIMDateMaxListKey];
    NSMutableArray *_minList = _dic[kIMDateMinListKey];
    
    
    [CalculateTool calculateFixMaxList:_maxList minList:_minList];
     */
    return _dic;
}
-(NSDictionary *)getUserDataByMonth2:(NSDate *)targetDate
{
    NSDictionary *_dic = [[DatabaseService defaultDatabaseService] getMonth:targetDate
                                                               userDataByUid:[GloubleProperty sharedInstance].   currentUserEntity.UI_userId];
    /*
    NSMutableArray *_maxList = _dic[kIMDateMaxListKey];
    NSMutableArray *_minList = _dic[kIMDateMinListKey];
    
    
    [CalculateTool calculateFixMaxList:_maxList minList:_minList];
     */
    
    
    return _dic;
}


-(NSDictionary *)getUserDataByYear2:(NSDate *)targetDate
{
    NSDictionary *_dic = [[DatabaseService defaultDatabaseService]
                                getYear:targetDate
                            userDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId];

    return _dic;
}


/* 查询时间提示信息 */
-(NSArray *)getNotice
{
    return [[DatabaseService defaultDatabaseService] getNoticeListByUid:
                        [GloubleProperty sharedInstance].currentUserEntity.UI_userId];
}

/* 查询用户和设备信息 从数据库存 */
-(NSArray *)getUserDeviceInfo
{
    return [[DatabaseService defaultDatabaseService] getUserDeviceInfoListByUid:
                            [GloubleProperty sharedInstance].currentUserEntity.UI_userId];
}


/**
 *  根据uid删除用户
 *
 *  @param uid 目标uid
 */
-(BOOL)deleteUserByUid:(NSString *)uid
{
    BOOL _flag = NO;
    
    if ([[DatabaseService defaultDatabaseService] deleteUser:uid] == 1) {
        _flag = YES;
    }
    
    return _flag;
}



-(UserInfoEntity *)getHostUser
{
    UserInfoEntity *_user = [GloubleProperty sharedInstance].currentUserEntity;

    return _user;

}

/**
 *  获取当前用户总数据量
 *
 *  @return 总数据量
 */
-(int)getTotalDataCount
{
    int _count = 0;
    
    UserInfoEntity *_user = [GloubleProperty sharedInstance].currentUserEntity;
    if (_user) {
        _count = [[DatabaseService defaultDatabaseService] getDataCountByUid:_user.UI_userId];
    }
    
    
    
    return _count;
}


/**
 *  获取当前用户所有数据
 *
 *  @return UserDataEntity列表
 */
-(NSArray *)getCurrentUserTotalData
{
    UserInfoEntity *_user = [GloubleProperty sharedInstance].currentUserEntity;
    if (_user) {
        NSArray *_ary =  [[DatabaseService defaultDatabaseService]
                                            getUserDataByUid:_user.UI_userId] ;
        
        NSMutableArray *_result = [[NSMutableArray alloc]init];
        int _iR = -1;
        
        for (int i = 0; i < _ary.count; i++) {
            
            UserDataEntity *_data   = _ary[i];
            
            _data.UD_pcEntityList = [CalculateTool calculatePhysicalCharacteristics:_data
                                                     height:[[self inputStr:_user.UI_height] floatValue]
                                                        age:[[self inputStr:_user.UI_age] intValue]
                                                        sex:[[self inputStr:_user.UI_sex] intValue]
                                                        uid:[self inputStr:_user.UI_userId] ];
            /*
            if ([self checkData:_data]) {
                _data.UD_dataStatus = DataStatus_normal;
            }else{
                _data.UD_dataStatus = DataStatus_exception;
            }
            */
            
            NSString *_dataKey      = _data.UD_CHECKDATE;
            if (_dataKey &&
                ![_dataKey isKindOfClass:[NSNull class]] &&
                _dataKey.length == 19
            ) {
                _dataKey = [_data.UD_CHECKDATE componentsSeparatedByString:@" "][0];
                NSDictionary *_dic = @{ @"date":_dataKey,
                                        @"list":[[NSMutableArray alloc]init] };
                if (_iR == -1) {
                    _iR = 0;
                    [_result addObject:_dic];
                }
                else{
                    _dic = _result[_iR];
                }
                
                
                if (![_dataKey isEqualToString:_dic[@"date"]]) {
                    _iR++;
                    _dic = @{ @"date":_dataKey,
                              @"list":[[NSMutableArray alloc]init] };
                    [_result addObject:_dic];
                }
                
                
                NSMutableArray *_dataList = _dic[@"list"];
                [_dataList addObject:_data];
                
                
            }
            
            
            
            
        }
        
        return _result;
    }
    else{
        return @[];
    }
    

}


-(void)getCurrentUserTotalDataByPageId:(int)pageId
                              callback:(GetHistoryDataByPageCallback)callback
{
    UserInfoEntity *_user = [GloubleProperty sharedInstance].currentUserEntity;
    if (_user && pageId >= 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *_ary =  [[DatabaseService defaultDatabaseService]
                              getUserDataByUid:_user.UI_userId
                              pageId:pageId
                              countPerPage:kHistoryDataCountPerPage] ;
            
            NSMutableArray *_result = [[NSMutableArray alloc]init];
            int _iR = -1;
            
            for (int i = 0; i < _ary.count; i++) {
                
                UserDataEntity *_data   = _ary[i];
                
                _data.UD_pcEntityList = [CalculateTool calculatePhysicalCharacteristics:_data
                                                                                 height:[[self inputStr:_user.UI_height] floatValue]
                                                                                    age:[[self inputStr:_user.UI_age] intValue]
                                                                                    sex:[[self inputStr:_user.UI_sex] intValue]
                                                                                    uid:[self inputStr:_user.UI_userId] ];
                
                
                NSString *_dataKey      = _data.UD_CHECKDATE;
                if (_dataKey &&
                    ![_dataKey isKindOfClass:[NSNull class]] &&
                    _dataKey.length == 19
                    ) {
                    _dataKey = [_data.UD_CHECKDATE componentsSeparatedByString:@" "][0];
                    NSDictionary *_dic = @{ @"date":_dataKey,
                                            @"list":[[NSMutableArray alloc]init] };
                    if (_iR == -1) {
                        _iR = 0;
                        [_result addObject:_dic];
                    }
                    else{
                        _dic = _result[_iR];
                    }
                    
                    
                    if (![_dataKey isEqualToString:_dic[@"date"]]) {
                        _iR++;
                        _dic = @{ @"date":_dataKey,
                                  @"list":[[NSMutableArray alloc]init] };
                        [_result addObject:_dic];
                    }
                    
                    
                    NSMutableArray *_dataList = _dic[@"list"];
                    [_dataList addObject:_data];
                    
                    
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (callback) {
                    callback(_result);
                }
            });
            
        });
        
        
    }
    else{
        if (callback) {
            callback(@[]);
        }
    }
    
    
}


#pragma mark - 购买相关请求
-(void)getProductInfoWithCallback:(WebRequestCallBack)callback
{
    _getProductInfoCallback = callback;
    [_userDataModel requestGetProductInfo];
}

-(void)getOrderWithCallback:(WebRequestCallBack)callback
                      buyer:(BR_BuyerEntity *)buyer
{
    
    
    NSMutableArray *_goodAry = [[NSMutableArray alloc]init];
    for (int i = 0; i < buyer.b_dataList.count; i++) {
        BR_ProductEntity *_product = buyer.b_dataList[i];
        
        
        [_goodAry addObject:@{@"productSn":_product.pt_sn,
                              @"productName":_product.pt_name,
                              @"productPrice":_product.pt_price,
                              @"productQuantity":[NSString stringWithFormat:@"%d",_product.pt_countOfBuy]
                              }];
    }
    
    NSString *_sign = [[buyer.b_member stringByAppendingString:buyer.b_password]
                                                        stringByAppendingString:@"ios"];
    
    NSData *_strData = [NSJSONSerialization
                                dataWithJSONObject:@{@"member":buyer.b_member,
                                                     @"password":buyer.b_password,
                                                     @"shipName":buyer.b_shipName,
                                                     @"shipAreaPath":buyer.b_shipAreaPath,
                                                     @"shipAddress":buyer.b_shipAddress,
                                                     @"shipMobile":buyer.b_shipMobile,
                                                     @"system":@"ios",
                                                     @"dataList":_goodAry,
                                                     @"type":buyer.b_menberType,
                                                     @"sign":[_sign md5String]}
                                            options:NSJSONWritingPrettyPrinted
                                              error:nil];
    
    NSDictionary *_param = @{@"parameter":[[NSString alloc]initWithData:_strData
                                                               encoding:NSUTF8StringEncoding]
                             };
    
    
    _getOrderInfoCallback = callback;
    [_userDataModel requestGetOrderNum:_param];
}


-(void)getWXPayGetAccessTokenWihtUrl:(NSString *)url
                            callback:(WXPayWebRequestCallback)callback
{
    if (url) {
        _wxPayGetAccessTokenCallback = callback;
        [_userDataModel requestWXGetAccessTokenWithUrl:url];
    }
    else
    {
        if (callback) {
            callback(NO,nil,@"url不能为空");
        }
    }
}


/**
 *  微信支付获取 PrepayId
 *
 *  @param url
 *  @param callback
 */
-(void)getWXPayGetPrepayIdWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                         callback:(WXPayWebRequestCallback)callback
{
    
    if (url) {
        if (params) {
            _wxPayGetPrepayIdCallback = callback;
            [_userDataModel requestWXGetPrepayIdWithUrl:url params:params];
        }
        else{
            if (callback) {
                callback(NO,nil,@"参数不能为空");
            }
        }
        
    }
    else
    {
        if (callback) {
            callback(NO,nil,@"url不能为空");
        }
    }
}


#pragma mark - 非网络，非数据库操作

-(NSString *)getUUID
{
    
    return [GloubleProperty sharedInstance].uuid;
}
-(void)saveUUID:(NSString *)uuid
{
    [GloubleProperty sharedInstance].uuid = uuid;
}

/* 定位 */
-(void)getLng_lat
{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (!_locManager) {
            _locManager = [[CLLocationManager alloc] init];
            _locManager.delegate = self;
            _locManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            _locManager.distanceFilter = 1000.0f;
        }
        
        
        [_locManager startUpdatingLocation];
        
    }else{
        
        if (!_locNotOpenAlertIsShow) {
            _locNotOpenAlertIsShow = 1;
            
//            [self showHUDInWindowJustWithText:@"定位服务未开启" disMissAfterDelay:0.5];
            /*
            UIAlertView *_alert =  [[UIAlertView alloc]initWithTitle:@"提 示"
                                                             message:@"定位服务未开启"
                                                            delegate:self
                                                   cancelButtonTitle:@"知道了"
                                                   otherButtonTitles:nil];
            _alert.tag = 9;
            [_alert show];
            */
        }
        
    }
    
}




/*  计算体征数据  */
-(NSDictionary *)calculatePhysicalCharacteristics:(UserDataEntity *)userData
                                           height:(float)height
                                              age:(int)age
                                              sex:(int)sex
                                              uid:(NSString *)uid
{
    if (!userData) {
        return @{
                     @"weight":@"",
                     @"bmi":@"",
                     @"fat":@"",
                     @"skin":@"",
                     @"offal":@"",
                     @"muscle":@"",
                     @"bmr":@"",
                     @"boneWeight":@"",
                     @"water":@"",
                     @"bodyage":@""
        };
    }
    
    
    float _bmi      = [[self inputStr:userData.UD_BMI] floatValue];
    float _weight   = [[self inputStr:userData.UD_WEIGHT] floatValue];
    float _fat      = [[self inputStr:userData.UD_FAT] floatValue];
    float _skin     = [[self inputStr:userData.UD_SKINFAT] floatValue];
    float _offal    = [[self inputStr:userData.UD_OFFALFAT] floatValue];
    float _muscle   = [[self inputStr:userData.UD_MUSCLE] floatValue];
    float _bmr      = [[self inputStr:userData.UD_METABOLISM] floatValue];
    float _bone     = [[self inputStr:userData.UD_BONE] floatValue];
    float _water    = [[self inputStr:userData.UD_WATER] floatValue];

    userData.UD_userId      = [self inputStr:uid];
    userData.UD_MEMID       = [self inputStr:uid];
    
    NSString *_wStr = @"";
    if (_bmi < 18.5) {
        _wStr = @"偏瘦";
    }else if (_bmi >= 18.5 && _bmi < 24){
        _wStr = @"标准";
    }else if (_bmi >= 24 && _bmi < 28){
        _wStr = @"超重";
    }else if (_bmi >= 28){
        _wStr = @"肥胖";
    }
    
    NSString *_bmiStr = @"";
    if (_bmi < 18.5) {
        _bmiStr = @"偏瘦";
    }
    else if (_bmi >= 18.5 && _bmi < 24){
        _bmiStr = @"标准";
    }
    else if (_bmi >= 24 && _bmi < 28){
        _bmiStr = @"超重";
    }
    else if (_bmi >= 28){
        _bmiStr = @"肥胖";
    }
    
    NSString *_fatStr = @"";

    if (sex) {
        if (age > 30) {
            if (_fat < 16) {
                _fatStr = @"偏瘦";
            }else if (_fat >= 16 && _fat < 23){
                _fatStr = @"标准";
            }else if (_fat >= 23 && _fat < 25){
                _fatStr = @"超重";
            }else if (_fat >= 25){
                _fatStr = @"肥胖";
            }
        }else{
            if (_fat < 13) {
                _fatStr = @"偏瘦";
            }else if (_fat >= 13 && _fat < 21){
                _fatStr = @"标准";
            }else if (_fat >= 21 && _fat < 25){
                _fatStr = @"超重";
            }else if (_fat >= 25){
                _fatStr = @"肥胖";
            }
        }
    }
    else{
        if (age > 30) {
            if (_fat < 19) {
                _fatStr = @"偏瘦";
            }else if (_fat >= 19 && _fat < 27){
                _fatStr = @"标准";
            }else if (_fat >= 27 && _fat < 30){
                _fatStr = @"超重";
            }else if (_fat >= 30){
                _fatStr = @"肥胖";
            }
        }else{
            if (_fat < 16) {
                _fatStr = @"偏瘦";
            }else if (_fat >= 16 && _fat < 23){
                _fatStr = @"标准";
            }else if (_fat >= 23 && _fat < 30){
                _fatStr = @"超重";
            }else if (_fat >= 30){
                _fatStr = @"肥胖";
            }
        }
    }
    
    NSString *_skinStr = @"";
    if (sex) {
        if (_skin < 8.6) {
            _skinStr = @"偏低";
        }else if (_skin >= 8.6 && _skin < 16.7){
            _skinStr = @"标准";
        }else if (_skin >= 16.7){
            _skinStr = @"偏高";
        }
    }
    else{
        if (_skin < 18.5) {
            _skinStr = @"偏低";
        }else if (_skin >= 18.5 && _skin < 26.7){
            _skinStr = @"标准";
        }else if (_skin >= 26.7){
            _skinStr = @"偏高";
        }
    }
    
    NSString *_offalStr = @"";
    if (_offal < 10) {
        _offalStr = @"偏低";
    }
    else if (_offal >= 10 && _offal <= 15)
    {
        _offalStr = @"标准";
    }
    else if (_offal > 15)
    {
        _offalStr = @"偏高";
    }
    
    NSString *_muscleStr = @"";
    if (sex) {
        
        float _minM = 0;
        float _maxM = 0;
        
        if (height <= 160) {
            
            _minM = 42.5 - 4;
            _maxM = 42.5 + 4;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
   
        }
        else if (height > 160 && height <= 170){
            
            _minM = 48.2 - 4.2;
            _maxM = 48.2 + 4.2;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
            
        }
        else if (height > 170){
            
            
            _minM = 54.4 - 5;
            _maxM = 54.4 + 5;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
            
        }
        
    }
    else{
        
        float _minM = 0;
        float _maxM = 0;
        
        if (height <= 150) {
            
            _minM = 31.9 - 2.8;
            _maxM = 31.9 + 2.8;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
            
        }
        else if (height > 150 && height <= 160){
            
            _minM = 35.2 - 2.3;
            _maxM = 35.2 + 2.3;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
            
        }
        else if (height > 160){
            
            
            _minM = 39.5 - 3;
            _maxM = 39.5 + 3;
            
            
            if (_muscle < _minM) {
                
                _muscleStr = @"偏低";
                
            }
            else if (_muscle >= _minM && _muscle <= _maxM)
            {
                _muscleStr = @"标准";
            }
            else if (_muscle > _maxM)
            {
                _muscleStr = @"偏高";
            }
            
        }
        
    }
    
    NSString *_bmrStr = @"";
    if (age >= 10 && age < 18)
    {
        float _standard = 17.5 * _weight + 651;
        if (_bmr < _standard) {
            _bmrStr = @"未达标";
        }else{
            _bmrStr = @"达标";
        }
    }
    else if (age >= 18 && age < 30)
    {
        float _standard = 15.3 * _weight + 679;
        if (_bmr < _standard) {
            _bmrStr = @"未达标";
        }else{
            _bmrStr = @"达标";
        }
    }
    else if (age >= 30)
    {
        float _standard = 11.6 * _weight + 879;
        if (_bmr < _standard) {
            _bmrStr = @"未达标";
        }else{
            _bmrStr = @"达标";
        }
    }
    
    NSString *_boneStr = @"";
    if (sex) {
        if (_bone < 3.1) {
            _boneStr = @"偏低";
        }
        else if (_bone >= 3.1 && _bone <= 3.3){
            _boneStr = @"标准";
        }
        else if (_bone > 3.3) {
            _boneStr = @"偏高";
        }
    }
    else{
        if (_bone < 2.4) {
            _boneStr = @"偏低";
        }
        else if (_bone >= 2.4 && _bone <= 2.6){
            _boneStr = @"标准";
        }
        else if (_bone > 2.6) {
            _boneStr = @"偏高";
        }
    }
    
    
    NSString *_waterStr = @"";
    if (sex) {
        if (age > 30) {
            if (_water < 53.3) {
                _waterStr = @"偏低";
            }else if (_water >= 53.3 && _water <= 55.6){
                _waterStr = @"标准";
            }else if (_water > 55.6){
                _waterStr = @"偏高";
            }
        }else{
            if (_water < 53.6) {
                _waterStr = @"偏低";
            }else if (_water >= 53.6 && _water <= 57){
                _waterStr = @"标准";
            }else if (_water > 57){
                _waterStr = @"偏高";
            }
        }
    }
    else{
        if (age > 30) {
            if (_water < 48.1) {
                _waterStr = @"偏低";
            }else if (_water >= 48.1 && _water <= 51.5){
                _waterStr = @"标准";
            }else if (_water > 51.5){
                _waterStr = @"偏高";
            }
        }else{
            if (_water < 49.5) {
                _waterStr = @"偏低";
            }else if (_water >= 49.5 && _water <= 52.9){
                _waterStr = @"标准";
            }else if (_water > 52.9){
                _waterStr = @"偏高";
            }
        }
    }
    
    
    
    NSString *_bodyageStr = @"";
    /*
    if (_bodyage > (age + 5) )
    {
        _bodyageStr = [NSString stringWithFormat:@">%d",(age + 5)];
    }
    else{
        _bodyageStr = [self inputStr:userData.UD_BODYAGE];
    }
    */
    
    NSDictionary *_dic = nil;
    
    if (![Helpers strIsEmty:uid]) {
        UserDataEntity *_lastData = [[DatabaseService defaultDatabaseService]
                                                    getUserDataByUid:uid num:2];
        if (_lastData) {
            
            NSNumber *_weightB      =
                    [NSNumber numberWithBool:
                            _weight > [[self inputStr:_lastData.UD_WEIGHT] floatValue]] ;
            NSNumber *_bmiB         =
                    [NSNumber numberWithBool:
                            _bmi > [[self inputStr:_lastData.UD_BMI] floatValue]] ;
            NSNumber *_fatB         =
                    [NSNumber numberWithBool:
                            _fat > [[self inputStr:_lastData.UD_FAT] floatValue]] ;
            NSNumber *_skinB        =
                    [NSNumber numberWithBool:
                            _skin > [[self inputStr:_lastData.UD_SKINFAT] floatValue]] ;
            NSNumber *_offalB       =
                    [NSNumber numberWithBool:
                            _offal > [[self inputStr:_lastData.UD_OFFALFAT] floatValue]] ;
            
            /*int*/
            NSNumber *_bmrB      =
                    [NSNumber numberWithBool:
                            _bmr > [[self inputStr:_lastData.UD_METABOLISM] floatValue]] ;
            
            
            NSNumber *_muscleB      =
                    [NSNumber numberWithBool:
                            _muscle > [[self inputStr:_lastData.UD_MUSCLE] floatValue]] ;
            NSNumber *_boneWeightB  =
                    [NSNumber numberWithBool:
                            _bone > [[self inputStr:_lastData.UD_BONE] floatValue]] ;
            NSNumber *_waterB       =
                    [NSNumber numberWithBool:
                            _water > [[self inputStr:_lastData.UD_WATER] floatValue]] ;
            
            
            /*int*/
            NSNumber *_bodyageB     =
                    [NSNumber numberWithBool:
                        [[self inputStr:userData.UD_BODYAGE] floatValue] >
                                    [[self inputStr:_lastData.UD_BODYAGE] floatValue] ] ;
            
            
            
            
            
            
            _dic = @{
                     @"weight":_wStr,
                     @"bmi":_bmiStr,
                     @"fat":_fatStr,
                     @"skin":_skinStr,
                     @"offal":_offalStr,
                     @"muscle":_muscleStr,
                     @"bmr":_bmrStr,
                     @"boneWeight":_boneStr,
                     @"water":_waterStr,
                     @"bodyage":@"",
                     @"weightB":_weightB,
                     @"bmiB":_bmiB,
                     @"fatB":_fatB,
                     @"skinB":_skinB,
                     @"offalB":_offalB,
                     @"muscleB":_muscleB,
                     @"bmrB":_bmrB,
                     @"boneWeightB":_boneWeightB,
                     @"waterB":_waterB,
                     @"bodyageB":_bodyageB,
                     };
        }
        else{
            _dic = @{
                     @"weight":_wStr,
                     @"bmi":_bmiStr,
                     @"fat":_fatStr,
                     @"skin":_skinStr,
                     @"offal":_offalStr,
                     @"muscle":_muscleStr,
                     @"bmr":_bmrStr,
                     @"boneWeight":_boneStr,
                     @"water":_waterStr,
                     @"bodyage":_bodyageStr
                };
        }
    }
    else{
    
        _dic = @{
                 @"weight":_wStr,
                 @"bmi":_bmiStr,
                 @"fat":_fatStr,
                 @"skin":_skinStr,
                 @"offal":_offalStr,
                 @"muscle":_muscleStr,
                 @"bmr":_bmrStr,
                 @"boneWeight":_boneStr,
                 @"water":_waterStr,
                 @"bodyage":_bodyageStr
                 };
        
    }
    
    
    
    
    return _dic;
}


/*  计算合理体重体  */
-(float)calculateWeight:(float)height
                    sex:(int)sex
{
    
    float _t = 0;
    if (sex) {
        _t = (height - 80) * 0.7;
    }
    else{
        _t = (height - 70) * 0.6;
    }
    return _t > 0 ? _t : 0;
}


/**
 *  测量数据校验
 *
 *  @param ude 要校验的数据
 */
-(BOOL)checkData:(UserDataEntity *)ude
{
    BOOL _flag = NO;
    
    
    if ([self dataIsNormal:ude]) {
        
        UserDataEntity *_lastData = [[DatabaseService defaultDatabaseService]
                                     getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId
                                     num:1];
        if (_lastData) {
            
            float _oldW = [ [self inputStr:_lastData.UD_WEIGHT]  floatValue];
            float _oldF = [ [self inputStr:_lastData.UD_FAT]  floatValue];
            float _newW = [ [self inputStr:ude.UD_WEIGHT]  floatValue];
            float _newF = [ [self inputStr:ude.UD_FAT]  floatValue];
            
            
            
            if ( fabsf((_oldW - _newW)) <= 2.5 ) {
                if ( fabsf((_oldF - _newF)) <= 30 ) {
                    _flag = YES;
                }
            }
            
        }else{
            _flag = YES;
        }
    }
    
    
    return _flag;
}


-(BOOL)getLoginState
{
    if (_loginState == 0) {
        return NO;
    }
    else{
        return YES;
    }

}

/**
 *  判断数据是否异常
 *
 *  @param data 需要检测数据
 *
 *  @return yes 正常，no 不正常
 */
-(BOOL)dataIsNormal:(UserDataEntity *)data
{
    BOOL _flag = YES;
    if (data) {
        
        float _weight = [[self inputStr:data.UD_WEIGHT] floatValue];
        float _water = [[self inputStr:data.UD_WATER] floatValue];
        float _muscle = [[self inputStr:data.UD_MUSCLE] floatValue];
        float _bone = [[self inputStr:data.UD_BONE] floatValue];
        float _bodyAge = [[self inputStr:data.UD_BODYAGE] floatValue];
        float _skin = [[self inputStr:data.UD_SKINFAT] floatValue];
        float _off = [[self inputStr:data.UD_OFFALFAT] floatValue];
        float _fat = [[self inputStr:data.UD_FAT] floatValue];
        float _bmr = [[self inputStr:data.UD_METABOLISM] floatValue];
        
        
        int _count = 0;
        
        if (_weight == 0) {
            _count++;
        }
        if (_water == 0) {
            _count++;
        }
        if (_muscle == 0) {
            _count++;
        }
        if (_bone == 0) {
            _count++;
        }
        if (_bodyAge == 0) {
            _count++;
        }
        if (_skin == 0) {
            _count++;
        }
        if (_off == 0) {
            _count++;
        }
        if (_fat == 0) {
            _count++;
        }
        if (_bmr == 0) {
            _count++;
        }
        
        if (_count > 4) {
            _flag = NO;
        }

    }else{
        _flag = NO;
    }
    
    
    
    
    return _flag;

}






#pragma mark- 第三方登录

-(void)jingDongLoginWithNavController:(UIViewController *)navController
                             callback:(JingDongLoginCallback)callback
{
    _jdLonginCallback = callback;
    
    
    [JDPlusModel loginWithAppKey:kJingDongAppKey
                       appSecret:kJingDongAppSecret
                  appRedirectUrl:kJingDongAppRedirect_URL
                     navBarColor:[UIColor blueColor]
             targetNavController:navController
                        callback:^(BOOL isSuccess, JDUserInfo *jdUserInfo) {
                            if (isSuccess) {
                                _tempJDUser = jdUserInfo;
                                
                                [self showHUDInWindowJustWithText:@"已授权，正在登录"];
                                
                                [_userInfomationModel
                                    requestJDLoginWithOpenId:jdUserInfo.uid
                                                    nickName:jdUserInfo.user_nick
                                 ];
                                
                            }
                            else{
                                if (_jdLonginCallback) {
                                    _jdLonginCallback(ThirdSideLoginResult_refuse,nil,
                                                      @"授权未通过");
                                    _jdLonginCallback = nil;
                                }
                            }
                        }];

}


/**
 *  第三方注册完毕后，善后登陆
 *
 *  @param user 用户信息对象
 */
-(void)thirdSideRegsiter:(UserInfoEntity *)user
{
    
    
    
    
    float _targetW =   [[InterfaceModel sharedInstance]
                        calculateWeight:[user.UI_height floatValue]
                        sex:[user.UI_age intValue]];
    user.UI_remindmode     = @"0";
    user.UI_remindcycle    = @"0";
    user.UI_isLoc          = @"3";
    user.UI_mode           = @"1";
    user.UI_plan           = @"2";
    user.UI_privacy        = @"1";
    user.UI_target         = [NSString stringWithFormat:@"%d",(int)_targetW];
    user.UI_deviceList     = [[NSMutableArray alloc]init];
    
    
    int _year = [Helpers getNowYear] - [[self inputStr:user.UI_age] intValue];    
    user.UI_birthday = [NSString stringWithFormat:@"%04d-01-01",_year];
    
    
    JDUserInfoEntity *_jdU  = [[JDUserInfoEntity alloc]init];
    _jdU.userId             = user.UI_userId;
    _jdU.uid                = _tempJDUser.uid;
    _jdU.user_nick          = _tempJDUser.user_nick;
    _jdU.access_token       = _tempJDUser.access_token;
    _jdU.refresh_token      = _tempJDUser.refresh_token;
    _jdU.expires_in         = [NSString stringWithFormat:@"%d",_tempJDUser.expires_in];
    _jdU.time               = [NSString stringWithFormat:@"%lf",_tempJDUser.time];
    
    user.UI_jdUser          = _jdU;
    
    
    _tempJDUser = nil;
    

    [[DatabaseService defaultDatabaseService] saveJDUser:_jdU];
    [[DatabaseService defaultDatabaseService] saveLoginUser:user];
    
    GloubleProperty *_gp    = [GloubleProperty sharedInstance];
    
    _gp.sessionId           = _tempSid;
    _gp.currentUserEntity   = user;

    NSUserDefaults *_udf = [NSUserDefaults standardUserDefaults] ;
    [_udf setObject:user.UI_userId forKey:@"userId"];
    [_udf setObject:_gp.sessionId forKey:@"sessionId"];
    [_udf synchronize];
    
    _loginState = 1;
    [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                       object:[GloubleProperty sharedInstance].currentUserEntity
                                                     userInfo:nil];
    [self updateUserInfoWithCallBack:nil];
    [self updateUserSettingWithCallBack:nil];
    
    AppDelegate *delegate =
                    (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate mainViewAppearWithUserInfo:_gp.currentUserEntity];
    
    
    
}


/**
 *  第三方授权完毕后，善后登陆
 *
 *  @param user 用户信息对象
 */
-(void)thirdSideLogin:(UserInfoEntity *)user
             callback:(JingDongGetUserInfoCallback)callback
{
    
    
    _jdGetUserInfoCallback  = callback;
    
    
    
    [[DatabaseService defaultDatabaseService] saveLoginUser:user];
        
        if (user)
        {
            [_userInfomationModel requestQueryLoginDataWithsessionId:[self inputStr:_tempSid]
                                                              userId:[self inputStr:user.UI_userId]
                                                            userInfo:@{@"uie":user,
                                                                       @"cmd":@"thirdlogin"}];
        }
        else
        {
            [_userInfomationModel requestQueryLoginDataWithsessionId:[self inputStr:_tempSid]
                                                              userId:[self inputStr:user.UI_userId]
                                                            userInfo:@{ @"cmd":@"thirdlogin" }];
        }

    
    
}

-(void)jingDongUpload:(JDDataEntity *)data
             callback:(WebCallBack)callback
{
    UserInfoEntity *_gp = [GloubleProperty sharedInstance].currentUserEntity;
    if (_gp && _gp.UI_jdUser) {
        [_userDataModel requestUploadJDDataWithData:data user:_gp.UI_jdUser userInfo:nil];
    }
    
}



#pragma mark - Response Delegate
- (void)responseCode:(int)code
            actionId:(int)actionId
                info:(id)info
         requestInfo:(id)requestInfo
{
    switch (actionId) {
        case LOGIN_REQUEST_CODE:
            [self loginCallBackWithCode:code info:info requestInfo:requestInfo];
            break;
        case SEND_VALID_CODE:
            [self getCheckCode:code info:info requestInfo:requestInfo];
            break;
        case REGISTER_BODY_SCALE_CODE:
            [self registerCallBackWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_DATA_CODE:
            [self getUserDataWithCode:code info:info requestInfo:requestInfo];
            break;
        case UPDATE_USER_INFO_CODE:
            [self updateUserInfoWithCode:code info:info requestInfo:requestInfo];
            break;
        case USER_SETTING_CODE:
            [self updateUserSettingWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_SETTING_CODE:
        {
            [self getUserSettingWithCode:code info:info requestInfo:requestInfo];
        }
            break;
        case UPLOADFILE_CODE:
            [self upLoadImageWithCode:code info:info requestInfo:requestInfo];
            break;
        case LOGOUT_REQUEST_CODE:
            [self userLogoutWithCode:code info:info requestInfo:requestInfo];
            break;
        case SUBMIT_DATA_CODE:
            [self submitUserDataWithCode:code info:info requestInfo:requestInfo];
            break;
        case SUBMIT_SUGGEST_CODE:
            [self submitSuggestWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_SUGGEST_CODE:
            [self querySuggestWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_NOTICE_CODE:
            [self queryNoticeWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_LOGIN_DATA_CODE:
            [self queryLoginDataWithCode:code info:info requestInfo:requestInfo];
            break;
        case MODIFY_PWD_CODE:
            [self changePasswordWithCode:code info:info requestInfo:requestInfo];
            break;
        case RESET_PWD_CODE:
            [self resetPasswordWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_DEV_CODE:
            [self getSoleDeviceCodeWithCode:code info:info requestInfo:requestInfo];
            break;
        case SUBMIT_BIND_CODE:
            [self submitBindWithCode:code info:info requestInfo:requestInfo];
            break;
        case CANCEL_BIND_CODE:
            [self cancelBindWithCode:code info:info requestInfo:requestInfo];
            break;
        case SUBMIT_BATCH_DATA_CODE:
            [self submitBatchDataWithCode:code info:info requestInfo:requestInfo];
            break;
        case SUBMIT_PRAISE_CODE:
            [self submitPraiseWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_PRAISE_CODE:
            [self queryPraiseWithCode:code info:info requestInfo:requestInfo];
            break;
        case QUERY_FOCUS_DATA_CODE:
            [self queryFriendListWithCode:code info:info requestInfo:requestInfo];
            break;
        case ADD_FOCUS_CODE:
            [self addFriendWithCode:code info:info requestInfo:requestInfo];
            break;
        case MRIGHT_FOCUS_CODE:
            [self modifyFriendRightWithCode:code info:info requestInfo:requestInfo];
            break;
        case DELETE_FOCUS_CODE:
            [self deleteFriendWithCode:code info:info requestInfo:requestInfo];
            break;
        case MY_SMG_COUNTS_CODE:
            [self getMSGWithCode:code info:info requestInfo:requestInfo];
            break;
        case AGREE_FOCUS_CODE:
            [self focusSetWithCode:code info:info requestInfo:requestInfo];
            break;
        case FOCUSME_LIST_CODE:
            [self getFocusMeListWithCode:code info:info requestInfo:requestInfo];
            break;
        case FOCUSME_SETREAD_CODE:
            [self setMsgReadedWithCode:code info:info requestInfo:requestInfo];
            break;
        case DEL_FOCUSMSG_CODE:
            [self delMsgWithCode:code info:info requestInfo:requestInfo];
            break;
        case THIRDSIDE_LOGIN_CODE:
            [self jingDongLoginWithCode:code info:info requestInfo:requestInfo];
            break;
        case DELETE_DATA_CODE:
            [self deleteDataWithCode:code info:info requestInfo:requestInfo];
            break;
        case CHECKCODE_INVALID_CODE:
            [self checkCodeInvalidWithCode:code info:info requestInfo:requestInfo];
            break;
        case GET_PROUDCTINFO_CODE:
            [self getProductInfoWithCode:code info:info requestInfo:requestInfo];
            break;
        case GET_ORDERINFO_CODE:
            [self getOrderWithWithCode:code info:info requestInfo:requestInfo];
            break;
        case GET_DEVCOLOR_CODE:
            [self getDevColorWithCode:code info:info requestInfo:requestInfo];
            break;
        case CHECK_LOGINNAME_CODE:
            [self checkLoginNameWithCode:code info:info requestInfo:requestInfo];
            break;
        default:
            break;
    }
}

#pragma mark - Response
- (void)loginCallBackWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        if ([info isKindOfClass:[NSDictionary class]])
        {
            
            UserInfoEntity *userInfoEntity  = [[UserInfoEntity alloc]init];
            
            userInfoEntity.UI_loginName     = [self inputStr:requestInfo[@"loginName"]];
            userInfoEntity.UI_loginPwd      = [self inputStr:requestInfo[@"loginPwd"]];
            
            userInfoEntity.UI_age           = [self inputStr:info[@"age"]];
            userInfoEntity.UI_cname         = [self inputStr:info[@"cname"]];
            userInfoEntity.UI_deviceNo      = [self inputStr:info[@"deviceNo"]];
            userInfoEntity.UI_focusModel    = [self inputStr:info[@"focusModel"]];
            userInfoEntity.UI_photoPath     = [self inputStr:info[@"photoPath"]];
            userInfoEntity.UI_sex           = [self inputStr:info[@"sex"]];
            userInfoEntity.UI_userId        = [self inputStr:info[@"userId"]];
            
            
            NSDictionary *_userInfo = requestInfo[@"userInfo"];
            NSString *_loc = nil;
            if (_userInfo) {
                _loc = [self inputStr:_userInfo[@"loc"]];
            }
            if ([@"" isEqualToString:_loc]) {
                userInfoEntity.UI_isLoc         = @"1";
            }
            else{
                userInfoEntity.UI_isLoc         = _loc;
                
            }
            
            
            
            
            
            if ([[DatabaseService defaultDatabaseService] saveLoginUser:userInfoEntity]) {
                
                NSString *_tpStr = @"login";
                if ([@"3" isEqualToString:_loc]) {
                    _tpStr = @"thirdlogin";
                }
                
                
                if (userInfoEntity)
                {
                    [_userInfomationModel requestQueryLoginDataWithsessionId:[self inputStr:info[@"sessionId"]]
                                                                      userId:[self inputStr:userInfoEntity.UI_userId]
                                                                    userInfo:@{@"uie":userInfoEntity,
                                                                               @"cmd":_tpStr}];
                }
                else
                {
                    [_userInfomationModel requestQueryLoginDataWithsessionId:[self inputStr:info[@"sessionId"]]
                                                                      userId:[self inputStr:userInfoEntity.UI_userId]
                                                                    userInfo:@{ @"cmd":_tpStr }];
                }
                
                
            }
            
        }
    }
    else
    { // 包括网络请求错误 以及请求参数错误
        if (![GloubleProperty sharedInstance].sessionId &&
            [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionId"]
            ) {
            [GloubleProperty sharedInstance].sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionId"];
        }
        
        if (_isReLogin) {
            _isReLogin = 0;
   
                [self disMissHUDWithText:@" " afterDelay:0];

            if ([info isKindOfClass:[NSDictionary class]]) {
                [self performSelector:@selector(showHUDInReLogin:) withObject:@1 afterDelay:1.5]; //[self disMissHUDWithText:@"登录超时,密码不正确,重新登录失败" afterDelay:1];
            }
            else{
                [self performSelector:@selector(showHUDInReLogin:) withObject:@0 afterDelay:1.5];
                //[self disMissHUDWithText:@"登录超时,网络异常,重新登录失败" afterDelay:1];
            }
        }
        else{

            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataFailure
                                                               object:nil
                                                             userInfo:nil];
            
            if ([info isKindOfClass:[NSDictionary class]]) {
                
                
                [self showAlert:[NSString stringWithFormat:@"loginCallBackWithCode:%@",[self inputStr:info[@"errorMsg"]]]];
                
                if (_loginCallBack) {
                    _loginCallBack(code, info,[self inputStr:info[@"errorMsg"]]);
                }
                
            }
            else{
                
                [self showAlert:@"loginCallBackWithCode:发送请求失败"];
                
                if (_loginCallBack) {
                    _loginCallBack(code, info, @"网络异常，请求失败");
                }
                
            }
            
            _loginCallBack = nil;
        }
        
        _isLogin =  0;
    }
}

-(void)showHUDInReLogin:(NSNumber *)flag
{
    if ([flag intValue]) {
        [self disMissHUDWithText:@"登录超时,密码不正确,重新登录失败" afterDelay:1];
    }else{
        [self disMissHUDWithText:@"登录超时,网络异常,重新登录失败" afterDelay:1];;
    }
}

- (void)getCheckCode:(int)code
                info:(id)info
         requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _getCheckCodeCallBack(code, nil);
            _getCheckCodeCallBack = nil;
        });
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        if ([info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"getCheckCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            

            dispatch_async(dispatch_get_main_queue(), ^{
                _getCheckCodeCallBack(code, [self inputStr:info[@"errorMsg"]]);
                _getCheckCodeCallBack = nil;
            });
            
        }else{
            

            if (_getCheckCodeCallBack) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _getCheckCodeCallBack(code, @"网络异常，请求失败");
                    _getCheckCodeCallBack = nil;
                });

            }
            
        }
    }
    
    
}

- (void)registerCallBackWithCode:(int)code
                            info:(id)info
                     requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        
        if ([info isKindOfClass:[NSDictionary class]])
        {

            UserInfoEntity *userInfoEntity  = [UserInfoEntity new];
            
            userInfoEntity.UI_loginName     = [self inputStr:requestInfo[@"loginName"]];
            userInfoEntity.UI_loginPwd      = [self inputStr:requestInfo[@"password"]];
            userInfoEntity.UI_sex           = [self inputStr:requestInfo[@"sex"]];
            userInfoEntity.UI_weight        = [self inputStr:requestInfo[@"weight"]];
            userInfoEntity.UI_height        = [self inputStr:requestInfo[@"height"]];
            
            userInfoEntity.UI_mode          = [self inputStr:requestInfo[@"mode"]];
            userInfoEntity.UI_plan          = [self inputStr:requestInfo[@"plan"]];
            userInfoEntity.UI_target        = [self inputStr:requestInfo[@"target"]];
            userInfoEntity.UI_privacy       = [self inputStr:requestInfo[@"privacy"]];
            userInfoEntity.UI_birthday      = [self inputStr:requestInfo[@"age"]];
            
            
            userInfoEntity.UI_userId        = [self inputStr:info[@"userId"]];
            userInfoEntity.UI_loginId       = [self inputStr:info[@"loginId"]];
            userInfoEntity.UI_nickname      = [self inputStr:requestInfo[@"nickName"]];

            userInfoEntity.UI_remindmode    = @"0";
            userInfoEntity.UI_remindcycle   = @"0";
            userInfoEntity.UI_isLoc         = @"1";
            userInfoEntity.UI_deviceList    = [[NSMutableArray alloc]init];
            
            [[DatabaseService defaultDatabaseService] saveLoginUser:userInfoEntity];

            GloubleProperty *_gp    = [GloubleProperty sharedInstance];
            
            _gp.sessionId           = [self inputStr:info[@"sessionId"]];
            _gp.currentUserEntity   = userInfoEntity;
            
            
            UserDataEntity *_regData = requestInfo[@"userData"];
            
            if (_regData) {
                userInfoEntity.UI_lastCheckDate = _regData.UD_CHECKDATE;
                _regData.UD_userId              = userInfoEntity.UI_userId;
                _regData.UD_MEMID               = userInfoEntity.UI_userId;
                _regData.UD_ID                  = @"-101";
                //[[DatabaseService defaultDatabaseService]saveRegUserData:_regData];
                
                
                [self submitUserData:_regData
                            deviceNo:_regData.UD_devcode
                                flag:YES
                        WithCallBack:nil];
                
            }
            
            userInfoEntity.UI_lastUserData = _regData;
            
            
            
            
            
            
            NSUserDefaults *_udf = [NSUserDefaults standardUserDefaults] ;
            [_udf setObject:userInfoEntity.UI_userId forKey:@"userId"];
            [_udf setObject:_gp.sessionId forKey:@"sessionId"];
            [_udf synchronize];
            
            
            
            
            _loginState = 1;

            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                               object:[GloubleProperty sharedInstance].currentUserEntity
                                                             userInfo:nil];
            
            
            if (_registerCallBack) {
                _registerCallBack(code, userInfoEntity,nil);
            }
            
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        if ([info isKindOfClass:[NSDictionary class]]) {

            
            [self showAlert:[NSString stringWithFormat:@"registerCallBackWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            if (_registerCallBack) {
                _registerCallBack(code, nil, [self inputStr:info[@"errorMsg"]]);
            }
            
            
        }else{
            
            [self showAlert:@"registerCallBackWithCode:发送请求失败"];
            if (_registerCallBack) {
                _registerCallBack(code, nil, @"网络异常，请求失败");
            }
            
            
        }
        
       
    }
    
     _registerCallBack = nil;
}

- (void)getUserDataWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{
    
        
    NSMutableArray *_dataList           = [[NSMutableArray alloc]init];
        
    if (code == REQUEST_SUCCESS_CODE)
    {
        _loginDate = [NSDate date];
        
        
        NSMutableArray *_responsedataList   = info[@"dataList"];

        if (_responsedataList && [_responsedataList isKindOfClass:[NSArray class]])
        {
            for (int i = 0; i < _responsedataList.count; i++)
            {
                NSDictionary *_tempData = _responsedataList[i];
                if (_tempData && [_tempData isKindOfClass:[NSDictionary class]]) {
                    UserDataEntity *_ud = [[UserDataEntity alloc]init];
                    
                    _ud.UD_ID           = [self inputStr:_tempData[@"id"]];
                    _ud.UD_MEMID        = requestInfo[@"userId"];
                    _ud.UD_WEIGHT       = [self inputStr:_tempData[@"weight"]];
                    _ud.UD_BMI          = [self inputStr:_tempData[@"bmi"]];
                    
                    _ud.UD_FAT          = [self inputStr:_tempData[@"fat"]];
                    _ud.UD_SKINFAT      = [self inputStr:_tempData[@"skinfat"]];
                    _ud.UD_OFFALFAT     = [self inputStr:_tempData[@"offalfat"]];
                    _ud.UD_MUSCLE       = [self inputStr:_tempData[@"muscle"]];
                    
                    _ud.UD_METABOLISM   = [self inputStr:_tempData[@"metabolism"]];
                    _ud.UD_WATER        = [self inputStr:_tempData[@"water"]];
                    _ud.UD_BONE         = [self inputStr:_tempData[@"bone"]];
                    _ud.UD_BODYAGE      = [self inputStr:_tempData[@"bodyage"]];
                    
                    _ud.UD_STATUS       = [self inputStr:_tempData[@"status"]];
                    _ud.UD_CHECKDATE    = [self inputStr:_tempData[@"checkdate"]];
                    _ud.UD_CREATETIME   = [self inputStr:_tempData[@"createtime"]];
                    _ud.UD_MODIFYTIME   = [self inputStr:_tempData[@"modifytime"]];
                    
                    _ud.UD_location     = [self inputStr:_tempData[@"location"]];;
                    _ud.UD_devcode      = [self inputStr:_tempData[@"devcode"]];;
                    _ud.UD_latit        = [self inputStr:_tempData[@"latit"]];;
                    _ud.UD_longit       = [self inputStr:_tempData[@"longit"]];
                    _ud.UD_ryFit        = [self inputStr:_tempData[@"ryfit"]];;
 
                    _ud.UD_isFriendData = @"0";
                    _ud.UD_userId       = requestInfo[@"userId"];
                    
                    [_dataList addObject:_ud];
                }
                
            }
            
            
            
            if (_dataList.count > 0) {
                [[DatabaseService defaultDatabaseService]saveUserData:_dataList];
                
            }
        }
        
        
        _dataList = [NSMutableArray arrayWithArray:
                     [[DatabaseService defaultDatabaseService]
                      getUserDataByUid:requestInfo[@"userId"]]] ;
        
        
        UserDataEntity *_lastUd = [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
        if (_lastUd) {
            
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
        }
        if (_getUserDataCallBack) {
            _getUserDataCallBack(code,_dataList, [self inputStr:info[@"errorMsg"]] );
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataChanged
                                                           object:nil
                                                         userInfo:nil];
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"getuserdatawithcode"];
        if (_getUserDataCallBack) {
            _getUserDataCallBack(code, info, @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            
            [self showAlert:[NSString stringWithFormat:@"getUserDataWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            if (_getUserDataCallBack) {
                _getUserDataCallBack(code, info, [self inputStr:info[@"errorMsg"]]);
            }
            
            
        }else{
            
            [self showAlert:@"getUserDataWithCode:发送请求失败"];
            if (_getUserDataCallBack) {
                _getUserDataCallBack(code, info, @"网络异常，请求失败");
            }
        }
    }
    
    _getUserDataCallBack = nil;
  
}

- (void)updateUserInfoWithCode:(int)code
                          info:(id)info
                   requestInfo:(id)requestInfo
{

    
    if (code == REQUEST_SUCCESS_CODE) {

        _loginDate = [NSDate date];
        
        [[DatabaseService defaultDatabaseService]
         saveLoginUser:[GloubleProperty sharedInstance].currentUserEntity];

        if (_upLoadImageCallBack) {
            _upLoadImageCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
        }
        
        
        if (_updateUserInfoWithCallBack) {
            _updateUserInfoWithCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
        }
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataChanged
                                                           object:nil
                                                         userInfo:nil];
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"updateuserinfowithcode"];
        if (_upLoadImageCallBack) {
            _upLoadImageCallBack(code,info, @"会话超时");
        }
        
        
        if (_updateUserInfoWithCallBack) {
            _updateUserInfoWithCallBack(code,info,@"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        if (info && [info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"updateUserInfoWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];

            
            if (_upLoadImageCallBack) {
                _upLoadImageCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
            }
            
            
            if (_updateUserInfoWithCallBack) {
                _updateUserInfoWithCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
            }
            

            
        }else{
            
            [self showAlert:@"updateUserInfoWithCode:发送请求失败"];
            
            if (_upLoadImageCallBack) {
                _upLoadImageCallBack(code,info,@"网络异常，请求失败");
            }
            
            
            if (_updateUserInfoWithCallBack) {
                _updateUserInfoWithCallBack(code,info,@"网络异常，请求失败");
            }

        }
    }
    
    _upLoadImageCallBack        = nil;
    _updateUserInfoWithCallBack = nil;

}

- (void)updateUserSettingWithCode:(int)code
                             info:(id)info
                      requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        
        _loginDate = [NSDate date];
        
        [[DatabaseService defaultDatabaseService]
         saveLoginUser:[GloubleProperty sharedInstance].currentUserEntity];

        if (_updateUserSettingCallBack) {
            _updateUserSettingCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
        }
  
        
    }
    else if (code == kRequestNoLogin)
    {
        //[self showHUDInWindowJustWithText:@"用户信息修改未成功" disMissAfterDelay:0.8];
        [self reLogin:@"updateuserSetting"];
        if (_updateUserSettingCallBack) {
            _updateUserSettingCallBack(code, info, @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        //[self showHUDInWindowJustWithText:@"用户信息修改未成功" disMissAfterDelay:0.8];
        if ([info isKindOfClass:[NSDictionary class]]) {
            

            [self showAlert:[NSString stringWithFormat:@"updateUserSettingWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];

            

            if (_updateUserSettingCallBack) {
                 _updateUserSettingCallBack(code, info, [self inputStr:info[@"errorMsg"]]);
            }
           
            
        }else{
            
            [self showAlert:@"updateUserSettingWithCode:发送请求失败"];
            
            if (_updateUserSettingCallBack) {
                _updateUserSettingCallBack(code, info,  @"网络异常，请求失败");
            }
            
        }
    }
    
    
    _updateUserSettingCallBack = nil;

}

- (void)upLoadImageWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{

    
    if (code == REQUEST_SUCCESS_CODE) {
        
    
        
        [GloubleProperty sharedInstance].currentUserEntity.UI_photoPath =
                                                    [self inputStr:info[@"fileUrl"]];
    

        
        [_userInfomationModel requestUpdateUserInformationWithsessionId:[GloubleProperty sharedInstance].sessionId
                                                                loginId:nil
                                                               passWord:nil
                                                              validCode:nil
                                                                    age:nil
                                                               nickname:nil
                                                                chnName:nil
                                                                    sex:nil
                                                         homeProvinceId:nil
                                                       homeProvinceName:nil
                                                             homeCityId:nil
                                                           homeCityname:nil
                                                             homeAreaId:nil
                                                           homeAreaName:nil
                                                         locaProvinceId:nil
                                                       locaProvinceName:nil
                                                             locaCityId:nil
                                                           locaCityName:nil
                                                             locaAreaId:nil
                                                           locaAreaName:nil
                                                              photoPath:[self inputStr:info[@"fileUrl"]]
                                                               birthday:nil
                                                                 height:nil
                                                                 weight:nil
                                                             profession:nil
                                                           privacyLevel:nil
                                                               authBind:nil
                                                                 status:nil
                                                                 remark:nil
                                                              regStatus:nil
                                                           bodyscaleLoc:nil];
 
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            

            [self showAlert:[NSString stringWithFormat:@"upLoadImageWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];


            
            if (_upLoadImageCallBack) {
                _upLoadImageCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
            }
        }else{
            
            [self showAlert:@"upLoadImageWithCode:发送请求失败"];
            
            if (_upLoadImageCallBack) {
                _upLoadImageCallBack(code,info,  @"网络异常，请求失败");
            }
        }
        
        
        _upLoadImageCallBack = nil;
    }
}



- (void)userLogoutWithCode:(int)code
                      info:(id)info
               requestInfo:(id)requestInfo
{
   

         _loginDate = nil;
        
        [GloubleProperty sharedInstance].currentUserEntity  = nil;
        [GloubleProperty sharedInstance].sessionId          = nil;
        
        NSUserDefaults *_udf = [NSUserDefaults standardUserDefaults];
        
        [_udf removeObjectForKey:@"userId"];
        [_udf removeObjectForKey:@"sessionId"];
        
        [_udf synchronize];
        if (_userLogoutCallBack) {

            _userLogoutCallBack(REQUEST_SUCCESS_CODE,@"",@"");
        }

    _userLogoutCallBack = nil;

}


- (void)submitUserDataWithCode:(int)code
                          info:(id)info
                   requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE)
    {
         _loginDate = [NSDate date];
        
        UserDataEntity *_ud = [[UserDataEntity alloc]init];
        
        _ud.UD_userId       = [self inputStr:requestInfo[@"userId"]];
        _ud.UD_WEIGHT       = [self inputStr:requestInfo[@"weight"]];
        _ud.UD_BMI          = [self inputStr:requestInfo[@"bmi"]];
        _ud.UD_FAT          = [self inputStr:requestInfo[@"fat"]];
        
        _ud.UD_SKINFAT      = [self inputStr:requestInfo[@"skinfat"]];
        _ud.UD_OFFALFAT     = [self inputStr:requestInfo[@"offalfat"]];
        _ud.UD_MUSCLE       = [self inputStr:requestInfo[@"muscle"]];
        _ud.UD_METABOLISM   = [self inputStr:requestInfo[@"metabolism"]];
        
        _ud.UD_WATER        = [self inputStr:requestInfo[@"water"]];
        _ud.UD_BONE         = [self inputStr:requestInfo[@"bone"]];
        _ud.UD_BODYAGE      = [self inputStr:requestInfo[@"bodyage"]];
        _ud.UD_CHECKDATE    = [self inputStr:requestInfo[@"checkdate"]];
        
       
        _ud.UD_MEMID        = [self inputStr:requestInfo[@"userId"]];
        _ud.UD_isFriendData = @"0";

        
        
        _ud.UD_location     = [self inputStr:requestInfo[@"location"]];
        _ud.UD_latit        = [self inputStr:requestInfo[@"latit"]];
        _ud.UD_longit       = [self inputStr:requestInfo[@"longit"]];
        _ud.UD_devcode      = [self inputStr:requestInfo[@"devcode"]];

        _ud.UD_STATUS       = [self inputStr:info[@"STATUS"]];
        _ud.UD_MODIFYTIME   = [self inputStr:info[@"MODIFYTIME"]];
        _ud.UD_CREATETIME   = [self inputStr:info[@"CREATETIME"]];
        _ud.UD_ID           = [self inputStr:info[@"id"]];
        
        [[DatabaseService defaultDatabaseService]saveSingleUserData:_ud];

        UserDataEntity *_lastUd = [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
        if (_lastUd) {
            
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
        }
        
        [[DatabaseService defaultDatabaseService] saveLoginUser:[GloubleProperty sharedInstance].currentUserEntity];

        
        [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataSubmitted
                                                           object:nil
                                                         userInfo:nil];
        
        if (_submitUserDataCallBack) {
            _submitUserDataCallBack(code,info, [self inputStr:info[@"errorMsg"]]);
        }
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"submituserdata"];
        if (_submitUserDataCallBack) {
            _submitUserDataCallBack(code,info, @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if (info && [info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"submitUserDataWithCode:%@",[self inputStr:info[@"errorMsg"]]]];
            
            
            
            if (_submitUserDataCallBack) {
                _submitUserDataCallBack(code,info,  @"网络异常，请求失败");
            }
            
        }else{
            
            [self showAlert:@"submitUserDataWithCode:发送请求失败"];
            
            
            if (_submitUserDataCallBack) {
                _submitUserDataCallBack(code,info,  @"网络异常，请求失败");
            }

        }
        
    }
    
    _submitUserDataCallBack = nil;
}

- (void)submitSuggestWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        if (_submitSuggestCallBack) {
            _submitSuggestCallBack(code,info, nil);
        }
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"submitSuggest"];
        if (_submitSuggestCallBack) {
            _submitSuggestCallBack(code,nil,@"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if (info && [info isKindOfClass:[NSDictionary class]]) {

            
            [self showAlert:[NSString stringWithFormat:@"submitSuggestWithCode:%@",[self inputStr:info[@"errorMsg"]]]];
            
            
            if (_submitSuggestCallBack) {
                _submitSuggestCallBack(code,nil,  @"网络异常，请求失败");
            }
            
        }else{

            [self showAlert:@"submitSuggestWithCode:发送请求失败"];
            
            if (_submitSuggestCallBack) {
                _submitSuggestCallBack(code,nil,  @"网络异常，请求失败");
            }
        }
        
        
    }

    _submitSuggestCallBack = nil;

}


-(void)querySuggestWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{

    
    
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        NSArray *_dataList      = info[@"dataList"];

        if (_dataList) {
            NSMutableArray *_saveSuggest = [[NSMutableArray alloc]init];
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_suggest = _dataList[i];
                
                if (_suggest && [_suggest isKindOfClass:[NSDictionary class]]) {
                    
                    SuggestEntity *_se = [[SuggestEntity alloc]init];

                    _se.S_id            = [self inputStr:_suggest[@"id"]] ;
                    _se.S_memid         = [self inputStr:_suggest[@"memid"]] ;
                    _se.S_admin         = [self inputStr:_suggest[@"admin"]];
                    _se.S_content       = [self inputStr:_suggest[@"content"]];
                    _se.S_suggesttype   = [self inputStr:_suggest[@"suggesttype"]];
                    _se.S_status        = [self inputStr:_suggest[@"status"]];
                    _se.S_createtime    = [self inputStr:_suggest[@"createtime"]];

                    [_saveSuggest addObject:_se];
                    
                }
            }
            
            [[DatabaseService defaultDatabaseService]saveSuggest:_saveSuggest
                                                             uid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId];
            
            
            
            
            
        }
        
        NSArray *_result = [[DatabaseService defaultDatabaseService]
                                getSuggestListByUiduid:
                                        [GloubleProperty sharedInstance].currentUserEntity.UI_userId];

                if (_querySuggestCallBack) {
                    _querySuggestCallBack(code, _result,nil );
                }
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"querySuggest"];

                if (_querySuggestCallBack) {
                    _querySuggestCallBack(code,nil, @"会话超时");
                }
        
    }
    else { // 包括网络请求错误 以及请求参数错误
        if (info && [info isKindOfClass:[NSDictionary class]]) {

            
            [self showAlert:[NSString stringWithFormat:@"querySuggestWithCode:%@",[self inputStr:info[@"errorMsg"] ]]];
            
            
                    if (_querySuggestCallBack) {
                        _querySuggestCallBack(code,nil,  @"网络异常，请求失败");
                    }
        }else{
            
            [self showAlert:@"querySuggestWithCode:发送请求失败"];
            
                    if (_querySuggestCallBack) {
                        _querySuggestCallBack(code,nil,  @"网络异常，请求失败");
                    }
  
        }
   
    }

            _querySuggestCallBack = nil;
}


-(void)queryNoticeWithCode:(int)code
                      info:(id)info
               requestInfo:(id)requestInfo
{

    int _tp = [(NSNumber *)requestInfo[@"userInfo"] intValue];
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        NSArray *_dataList = info[@"dataList"];

        
        GloubleProperty *_gp        = [GloubleProperty sharedInstance];
        NSString *_uid              = @"";
        if (_gp.currentUserEntity) {
            _uid = _gp.currentUserEntity.UI_userId;
        }

        
        if (_dataList) {
            NSMutableArray *_saveNotice = [[NSMutableArray alloc]init];
            
            
            
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_notice = _dataList[i];
                if (_notice && [_notice isKindOfClass:[NSDictionary class]]) {
                    NoticeEntity *_ne = [[NoticeEntity alloc]init];

                    _ne.N_id            = [self inputStr:_notice[@"id"]] ;
                    _ne.N_userId        = _uid ;
                    _ne.N_time          = [self inputStr:_notice[@"time"]];
                    _ne.N_picurl        = [self inputStr:_notice[@"picurl"]];
                    _ne.N_noticetype    = [self inputStr:_notice[@"noticetype"]];
                    _ne.N_content       = [self inputStr:_notice[@"content"]];
                    _ne.N_actionName    = [self inputStr:_notice[@"actionName"]];

                    [_saveNotice addObject:_ne];
                }
                
            }
            [[DatabaseService defaultDatabaseService]saveNotices:_saveNotice
                                                             uid:_uid];
            
            
        }
        

        
        
        switch (_tp) {
            case 0:
            {
                NSArray *_result = [[DatabaseService defaultDatabaseService]getNoticeListByUid:_uid];
                if (_queryNoticeCallBack) {
                    _queryNoticeCallBack(code, _result, nil );
                }
            }
                break;
            case 1:
            {
                NoticeEntity *_result = [[DatabaseService defaultDatabaseService]getNowNoticeByUid:_uid];
                NSString *_rStr = @"";
                if (_result) {
                    _rStr = [NSString stringWithFormat:@"%@ %@:%@",
                             _result.N_time,
                             _result.N_actionName,
                             _result.N_content];
                    
                    ;
                }

                if (_queryNowNoticeCallBack) {
                    _queryNowNoticeCallBack(YES, _rStr, nil );
                }
            }
                break;
            default:
                break;
        }
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"querynotice"];
        
        switch (_tp) {
            case 0:
            {
                if (_queryNoticeCallBack) {
                    _queryNoticeCallBack(code,nil, @"会话超时");
                }
            }
                break;
            case 1:
            {
                if (_queryNowNoticeCallBack) {
                    _queryNowNoticeCallBack(NO,nil, @"");
                }
            }
                break;
            default:
                break;
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        if ([info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"queryNoticeWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];

            
            
            switch (_tp) {
                case 0:
                {
                    if (_queryNoticeCallBack) {
                        _queryNoticeCallBack(code,nil, [self inputStr:info[@"errorMsg"]]);
                    }
                }
                    break;
                case 1:
                {
                    if (_queryNowNoticeCallBack) {
                        _queryNowNoticeCallBack(NO,nil, @"");
                    }
                }
                    break;
                default:
                    break;
            }
            
        }else{
            
            [self showAlert:@"queryNoticeWithCode:发送请求失败"];
            
            
            switch (_tp) {
                case 0:
                {
                    if (_queryNoticeCallBack) {
                        _queryNoticeCallBack(code,nil,  @"网络异常，请求失败");
                    }
                }
                    break;
                case 1:
                {
                    if (_queryNowNoticeCallBack) {
                        _queryNowNoticeCallBack(NO,nil, @"");
                    }
                }
                    break;
                default:
                    break;
            }
 
        }
   
    }
    switch (_tp) {
        case 0:
        {
            _queryNoticeCallBack = nil;
        }
            break;
        case 1:
        {
            _queryNowNoticeCallBack = nil;
        }
            break;
        default:
            break;
    }
    
}

-(void)queryLoginDataWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{

    NSDictionary *_info = requestInfo[@"userInfo"];
    NSString *_cmdStr = @"";
    if (_info) {
        _cmdStr = _info[@"cmd"];
    }
    UserInfoEntity *_user      = nil;
    if (_info) {
        _user = _info[@"uie"];
    }
    

    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
  
        
        GloubleProperty *_gp       = [GloubleProperty sharedInstance];

        _gp.sessionId              = [self inputStr:requestInfo[@"sessionId"]];
        
        _loginDate = [NSDate date];
        if (_isReLogin) {
            _isReLogin = 0;
            [self disMissHUDWithText:@"登录超时，重新登录成功" afterDelay:1];
        }

         NSUserDefaults *_udf = [NSUserDefaults standardUserDefaults];
        
         [_udf setObject:_gp.sessionId forKey:@"sessionId"];
        
        
        
        if (_user) {
            
            [_udf setObject:_user.UI_userId forKey:@"userId"];
            
            
            _gp.currentUserEntity  = _user;
            _user.UI_nickname      = [self inputStr:info[@"nickname"]];
            _user.UI_loginId       = [self inputStr:info[@"loginid"]];
            _user.UI_age           = [self inputStr:info[@"age"]];
            _user.UI_birthday      = [self inputStr:info[@"birthday"]];
            _user.UI_cname         = [self inputStr:info[@"cname"]];
            
            _user.UI_photoPath     = [self inputStr:info[@"photopath"]];
            _user.UI_sex           = [self inputStr:info[@"sex"]];
            _user.UI_weight        = [self inputStr:info[@"weight"]];
            _user.UI_fat           = [self inputStr:info[@"fat"]];
            
            _user.UI_height        = [self inputStr:info[@"height"]];
            _user.UI_lastCheckDate = [self inputStr:info[@"checkdate"]];
            
            _user.UI_lastlocation  = [self inputStr:info[@"location"]];
            _user.UI_url           = [self inputStr:info[@"url"]];
            
            NSString *_mode        = [self inputStr:info[@"mode"]];
            _user.UI_mode          = [@"" isEqualToString:_mode]?@"1":_mode;
            NSString *_cPraise     = [self inputStr:info[@"countpraise"]];
            _user.UI_countpraise   = [@"" isEqualToString:_cPraise]?@"0":_cPraise;
            
   
        }
        
        [_udf synchronize];

        [GloubleProperty sharedInstance].url = info[@"url"] ;
        
        
        [[DatabaseService defaultDatabaseService] saveLoginUser:_user];
        
        
        NSArray *_dataList = info[@"dataList"];

        
        
        
        NSMutableArray *_saveUDI = [[NSMutableArray alloc]init];
        if (_dataList){
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_udiDic = _dataList[i];
                
                UserDeviceInfoEntity *_udi  = [[UserDeviceInfoEntity alloc]init];
                
                _udi.UDI_id                 = [self inputStr:_udiDic[@"id"]] ;
                _udi.UDI_memid              = [self inputStr:_udiDic[@"memid"]];
                _udi.UDI_devcode            = [self inputStr:_udiDic[@"devcode"]];
                _udi.UDI_status             = [self inputStr:_udiDic[@"status"]];
                
                _udi.UDI_location           = [self inputStr:_udiDic[@"location"]];
                _udi.UDI_createtime         = [self inputStr:_udiDic[@"createtime"]];
                _udi.UDI_modifytime         = [self inputStr:_udiDic[@"modifytime"]];
                
                [_saveUDI addObject:_udi];
                
            }
            [[DatabaseService defaultDatabaseService] saveUserDeviceInfos:_saveUDI
                                                                      uid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId];
        }
        [GloubleProperty sharedInstance].currentUserEntity.UI_deviceList = _saveUDI;
        
        
        
        
        
        
        
        UserDataEntity *_lastUd =
                [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
        if (_lastUd)
        {
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
            [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
        }
        
        [self getUserSettingWithCallBack:nil];
        [self getUserDataWithCallBack2:nil];
        
        
        
        
        if ([@"login" isEqualToString:_cmdStr]) {
            
            _loginState = 1;

            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                               object:[GloubleProperty sharedInstance].currentUserEntity
                                                             userInfo:nil];
            
            
            if (_loginCallBack) {
                _loginCallBack(code,
                               [GloubleProperty sharedInstance].currentUserEntity,
                               [self inputStr:info[@"errorMsg"]]);
                
                
                [self longinTest:_user];
                
            }
            
        }
        
        if ([@"bind" isEqualToString:_cmdStr]) {
            
            if (_submitBindCallBack) {
                _submitBindCallBack(code, [GloubleProperty sharedInstance].currentUserEntity, [self inputStr:info[@"errorMsg"]]);
            }
            
        }
        
        if ([@"thirdlogin" isEqualToString:_cmdStr]) {
            _loginState = 1;

            
            JDUserInfoEntity *_jdU = nil;
            
            
            if (_tempJDUser) {
                _jdU                = [[JDUserInfoEntity alloc]init];
                _jdU.userId         = [GloubleProperty sharedInstance].currentUserEntity.UI_userId;
                _jdU.uid            = _tempJDUser.uid;
                _jdU.user_nick      = _tempJDUser.user_nick;
                _jdU.access_token   = _tempJDUser.access_token;
                _jdU.refresh_token  = _tempJDUser.refresh_token;
                _jdU.expires_in     = [NSString stringWithFormat:@"%d",_tempJDUser.expires_in];
                _jdU.time           = [NSString stringWithFormat:@"%lf",_tempJDUser.time];
                [[DatabaseService defaultDatabaseService]saveJDUser:_jdU];
                
                _tempJDUser = nil;
            }
            else{
                _jdU = [[DatabaseService defaultDatabaseService]
                                getJDUserByUid:_gp.currentUserEntity.UI_userId];
            }
           

            [GloubleProperty sharedInstance].currentUserEntity.UI_jdUser = _jdU;
            [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataOk
                                                               object:[GloubleProperty sharedInstance].currentUserEntity
                                                             userInfo:nil];
            
            if (_jdGetUserInfoCallback) {
                _jdGetUserInfoCallback(YES,nil);
            }
            
            if (_loginCallBack) {
                _loginCallBack(code,
                               [GloubleProperty sharedInstance].currentUserEntity,
                                        [self inputStr:info[@"errorMsg"]]);
                
                
                [self longinTest:_user];
                
            }
            
        }
        
 
    }
    else if (code == kRequestNoLogin)
    {
        
        if ([@"thirdlogin" isEqualToString:_cmdStr]) {

            if ([@"thirdlogin" isEqualToString:_cmdStr]) {
                if (_jdGetUserInfoCallback) {
                    _jdGetUserInfoCallback(NO,@"会话超时");
                }
                if (_loginCallBack) {
                    _loginCallBack(code, nil, @"会话超时");
                }
            }
        }
        else{
            
            [self reLogin:@"queryloginData"];
            if ([@"login" isEqualToString:_cmdStr]) {
                
                if (_loginCallBack) {
                    _loginCallBack(code, info, @"会话超时");
                }
                
            }
            
            if ([@"bind" isEqualToString:_cmdStr]) {
                
                if (_submitBindCallBack) {
                    _submitBindCallBack(code, info, @"会话超时");
                }
                
            }
        
        }
    }
    else
    { // 包括网络请求错误 以及请求参数错误

        if (_isReLogin) {
            _isReLogin = 0;
            
            if ([info isKindOfClass:[NSDictionary class]]) {
                [self disMissHUDWithText:@"登录超时,用户信息获取,重新登录失败" afterDelay:1];
            }
            else{
                [self disMissHUDWithText:@"登录超时,网络异常,重新登录失败" afterDelay:1];
            }
        }
        else{
            

                [[NSNotificationCenter defaultCenter]postNotificationName:kIMLoginDataFailure
                                                                   object:nil
                                                                 userInfo:nil];
            
            
        }

        
        
        if ([info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"queryLoginDataWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            if ([@"login" isEqualToString:_info[@"cmd"]]) {
                
                if (_loginCallBack) {
                    _loginCallBack(code, [GloubleProperty sharedInstance].currentUserEntity, [self inputStr:info[@"errorMsg"]]);
                }
                
            }
            
            if ([@"bind" isEqualToString:_info[@"cmd"]]) {
                
                if (_submitBindCallBack) {
                    _submitBindCallBack(code, [GloubleProperty sharedInstance].currentUserEntity, [self inputStr:info[@"errorMsg"]]);
                }
                
            }
            
            if ([@"thirdlogin" isEqualToString:_cmdStr]) {
                if (_jdGetUserInfoCallback) {
                    _jdGetUserInfoCallback(NO,[self inputStr:info[@"errorMsg"]]);
                }
                if (_loginCallBack) {
                    _loginCallBack(code, nil, [self inputStr:info[@"errorMsg"]]);
                }
            }
  
        }
        else{

            [self showAlert:@"queryLoginDataWithCode:发送请求失败"];
            
            if ([@"login" isEqualToString:_info[@"cmd"]]) {
                
                if (_loginCallBack) {
                    _loginCallBack(code, info, @"网络异常，请求失败");
                }
                
            }
            
            if ([@"bind" isEqualToString:_info[@"cmd"]]) {
                
                if (_submitBindCallBack) {
                    _submitBindCallBack(code, info,  @"网络异常，请求失败");
                }
                
            }
            
            if ([@"thirdlogin" isEqualToString:_cmdStr]) {
                if (_jdGetUserInfoCallback) {
                    _jdGetUserInfoCallback(NO,@"网络异常，请求失败");
                }
                
                if (_loginCallBack) {
                    _loginCallBack(code, info, @"网络异常，请求失败");
                }
            }
        }
    }
    
    
    if ([@"login" isEqualToString:_cmdStr]) {
        
        _loginCallBack      = nil;
        
    }
    
    if ([@"bind" isEqualToString:_cmdStr]) {
        
        _submitBindCallBack = nil;
        
    }
    
    if ([@"thirdlogin" isEqualToString:_cmdStr]) {

        _loginCallBack = nil;
    }
    
    _isLogin =  0;
    
}

-(void)changePasswordWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {

        _loginDate = [NSDate date];
        
        [GloubleProperty sharedInstance].currentUserEntity.UI_loginPwd = requestInfo[@"newPwd"];
        
        [[DatabaseService defaultDatabaseService]saveLoginUser:[GloubleProperty sharedInstance].currentUserEntity];
        /*
        if (!) {
            NSLog(@"changePasswordWithCode-保存用户信息失败");
        }
         */
        if (_requestChangePWDCallBack) {
            _requestChangePWDCallBack(code,
                              info,
                              [self inputStr:info[@"errorMsg"]]);
        }
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"changepassword"];
        if (_requestChangePWDCallBack) {
            _requestChangePWDCallBack(code,
                                      info,
                                      @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            

            [self showAlert:[NSString stringWithFormat:@"changePasswordWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            

            if (_requestChangePWDCallBack) {
                _requestChangePWDCallBack(code,
                                          info,
                                          [self inputStr:info[@"errorMsg"]]);
            }
            
        }else{

            [self showAlert:@"changePasswordWithCode:发送请求失败"];

            if (_requestChangePWDCallBack) {
                _requestChangePWDCallBack(code,
                                          info,
                                           @"网络异常，请求失败");
            }
        }
        
        
    }
    
    
    _requestChangePWDCallBack = nil;
}

-(void)resetPasswordWithCode:(int)code
                        info:(id)info
                 requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        
        if (_requestResetPWDCallBack) {
            _requestResetPWDCallBack(code,
                              info,
                              [self inputStr:info[@"errorMsg"]]);
        }
        
    }
    
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            

            [self showAlert:[NSString stringWithFormat:@"resetPasswordWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            

            if (_requestResetPWDCallBack) {
                _requestResetPWDCallBack(code,
                                         info,
                                         [self inputStr:info[@"errorMsg"]]);
            }
            
        }else{

            [self showAlert:@"resetPasswordWithCode:发送请求失败"];
            
            if (_requestResetPWDCallBack) {
                _requestResetPWDCallBack(code,
                                         info,
                                          @"网络异常，请求失败");
            }
            
        }
        
        
    }
    
    
    _requestResetPWDCallBack = nil;
}

-(void)getSoleDeviceCodeWithCode:(int)code
                            info:(id)info
                     requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        if (_getSoleDeviceCodeCallBack) {
            _getSoleDeviceCodeCallBack(code,
                                     [self inputStr:info[@"devCode"]],
                                     [self inputStr:info[@"errorMsg"]]);
        }
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"getsoleDevice"];
        if (_getSoleDeviceCodeCallBack) {
            _getSoleDeviceCodeCallBack(code,
                                       info,
                                       @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            [self showAlert:[NSString stringWithFormat:@"getSoleDeviceCodeWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            if (_getSoleDeviceCodeCallBack) {
                _getSoleDeviceCodeCallBack(code,
                                           info,
                                           [self inputStr:info[@"errorMsg"]]);
            }
            
            
        }else{

            [self showAlert:@"getSoleDeviceCodeWithCode:发送请求失败"];
            if (_getSoleDeviceCodeCallBack) {
                _getSoleDeviceCodeCallBack(code,
                                           info,
                                            @"网络异常，请求失败");
            }
        }
        
        
    }
    
    _getSoleDeviceCodeCallBack = nil;
}

-(void)submitBindWithCode:(int)code
                     info:(id)info
              requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        
        GloubleProperty *_gp    = [GloubleProperty sharedInstance];
        
        if (_gp.currentUserEntity) {
            [_userInfomationModel requestQueryLoginDataWithsessionId:[self inputStr:_gp.sessionId]
                                                              userId:[self inputStr:_gp.currentUserEntity.UI_userId]
                                                            userInfo:@{@"uie":_gp.currentUserEntity,
                                                                       @"cmd":@"bind"}];
        }
        else{
        
            _submitBindCallBack(REQUEST_FAILURE_CODE,@{@"errorMsg":@"登录对象不存在"},@"登录对象不存在");
        }
        
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"submitBind"];
        if (_submitBindCallBack) {
            _submitBindCallBack(code,info,@"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        if ([info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"submitBindWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];

            
            
            if (_submitBindCallBack) {
                _submitBindCallBack(code,info,[self inputStr:info[@"errorMsg"]]);
            }
            
        }
        else{

            [self showAlert:@"submitBindWithCode:发送请求失败"];

            if (_submitBindCallBack) {
                _submitBindCallBack(code,info, @"网络异常，请求失败");
            }
            
        }
        
        _submitBindCallBack = nil;
        
    }
}

-(void)cancelBindWithCode:(int)code
                     info:(id)info
              requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate              = [NSDate date];
        GloubleProperty *_gp    = [GloubleProperty sharedInstance];

        NSString *_devStr       = requestInfo[@"devCode"];
        NSString *_bindId       = requestInfo[@"bindId"];

        
        if (_bindId && _gp.currentUserEntity) {
            
            NSArray *_ary = _gp.currentUserEntity.UI_deviceList;
            
            if (_ary) {
                
                int j = -1;
                for (int i = 0; i < _ary.count; i++) {
                    UserDeviceInfoEntity *_udie = _ary[i];
                    
                    if ([_bindId isEqualToString:_udie.UDI_id]) {
                        
                        j = i;
                        
                        break;
                    }
                }

                if (j != -1) {
                    NSMutableArray *_aryNew = [NSMutableArray arrayWithArray:_ary];
                    [_aryNew removeObjectAtIndex:j];
                    
                    _gp.currentUserEntity.UI_deviceList = _aryNew;
                }
                
                
            }
        }
        else{
            if (_gp.currentUserEntity && _gp.currentUserEntity.UI_deviceList) {
                
                NSMutableArray *_idList = [[NSMutableArray alloc]init];
                
                for (int i = 0; i < _gp.currentUserEntity.UI_deviceList.count; i++) {
                    UserDeviceInfoEntity *_udie = _gp.currentUserEntity.UI_deviceList[i];
                    
                    if ([_devStr isEqualToString:_udie.UDI_devcode]) {
                        [_idList addObject:[NSNumber numberWithInt:i]];
                    }
                }
                
                NSMutableArray *_ary = [NSMutableArray arrayWithArray:_gp.currentUserEntity.UI_deviceList];
                
                for (int i = 0; i < _idList.count; i++) {
                    [_ary removeObjectAtIndex:[(NSNumber *)_idList[i] intValue]];
                }
                if (_ary.count > 0) {
                    _gp.currentUserEntity.UI_deviceList = _ary;
                }else{
                    _gp.currentUserEntity.UI_deviceList = nil;
                }
                
                
            }
        }
        
        if (_cancelBindCallBack) {
            _cancelBindCallBack(code, [GloubleProperty sharedInstance].currentUserEntity, nil);
        }
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"cancelBind"];
        if (_cancelBindCallBack) {
            _cancelBindCallBack(code,info,@"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {

            [self showAlert:[NSString stringWithFormat:@"cancelBindWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];

            
            
            if (_cancelBindCallBack) {
                _cancelBindCallBack(code,info,info[@"errorMsg"]);
            }
            
            
        }else{

            
            [self showAlert:@"cancelBindWithCode:发送请求失败"];

            if (_cancelBindCallBack) {
                _cancelBindCallBack(code,info, @"网络异常，请求失败");
            }
        }
        
        
    }
    
    _cancelBindCallBack = nil;
}

-(void)submitBatchDataWithCode:(int)code
                          info:(id)info
                   requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE)
    {
        _loginDate = [NSDate date];
        NSMutableArray *_responsedataList   = info[@"dataList"];
        
        
        [[DatabaseService defaultDatabaseService]deleteDataByDid:@"-1010"];
        
        
        if (_responsedataList &&
            [_responsedataList isKindOfClass:[NSArray class]] &&
            _responsedataList.count > 0
        ){

            for (int i = 0; i < _responsedataList.count; i++)
            {
                NSDictionary *_tempData = _responsedataList[i];
                
                UserDataEntity *_ud = [[UserDataEntity alloc]init];
                
                _ud.UD_ID           = [self inputStr:_tempData[@"id"]];
                _ud.UD_MEMID        = [self inputStr:_tempData[@"userId"]];
                _ud.UD_WEIGHT       = [self inputStr:_tempData[@"weight"]];
                _ud.UD_BMI          = [self inputStr:_tempData[@"bmi"]];
                
                _ud.UD_FAT          = [self inputStr:_tempData[@"fat"]];
                _ud.UD_SKINFAT      = [self inputStr:_tempData[@"skinfat"]];
                _ud.UD_OFFALFAT     = [self inputStr:_tempData[@"offalfat"]];
                _ud.UD_MUSCLE       = [self inputStr:_tempData[@"muscle"]];
                
                _ud.UD_METABOLISM   = [self inputStr:_tempData[@"metabolism"]];
                _ud.UD_WATER        = [self inputStr:_tempData[@"water"]];
                _ud.UD_BONE         = [self inputStr:_tempData[@"bone"]];
                _ud.UD_BODYAGE      = [self inputStr:_tempData[@"bodyage"]];
                
                _ud.UD_STATUS       = [self inputStr:_tempData[@"status"]];
                _ud.UD_CHECKDATE    = [self inputStr:_tempData[@"checkdate"]];
                _ud.UD_CREATETIME   = [self inputStr:_tempData[@"cratetime"]];
                _ud.UD_MODIFYTIME   = [self inputStr:_tempData[@"modifytime"]];
                
                _ud.UD_location     = [self inputStr:_tempData[@"location"]];;
                _ud.UD_devcode      = [self inputStr:_tempData[@"devcode"]];;
                _ud.UD_latit        = [self inputStr:_tempData[@"latit"]];;
                _ud.UD_longit       = [self inputStr:_tempData[@"longit"]];;
                
                _ud.UD_isFriendData = @"0";
                _ud.UD_userId       = [self inputStr:_tempData[@"userId"]];
                
                [[DatabaseService defaultDatabaseService]saveSingleUserData:_ud];
            }
            
            
            UserDataEntity *_lastUd = [[DatabaseService defaultDatabaseService]getUserDataByUid:[GloubleProperty sharedInstance].currentUserEntity.UI_userId num:1];
            if (_lastUd) {
                
                [GloubleProperty sharedInstance].currentUserEntity.UI_lastCheckDate = _lastUd.UD_CHECKDATE;
                [GloubleProperty sharedInstance].currentUserEntity.UI_lastUserData  = _lastUd;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataChanged
                                                               object:nil
                                                             userInfo:nil];
        }
        if (_submitBatchDataCallBack ) {
            _submitBatchDataCallBack(code, nil,  nil );
        }
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"submitBatchData"];
        if (_submitBatchDataCallBack) {
            _submitBatchDataCallBack(code, nil, @"会话超时");
        }
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            
            [self showAlert:[NSString stringWithFormat:@"submitBatchDataWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            if (_submitBatchDataCallBack) {
                _submitBatchDataCallBack(code, nil, [self inputStr:info[@"errorMsg"]]);
            }
            
            
        }else{
            
            [self showAlert:@"submitBatchDataWithCode:发送请求失败"];
            if (_submitBatchDataCallBack) {
                _submitBatchDataCallBack(code, nil,  @"网络异常，请求失败");
            }
            
        }
        
    }
    
    
    _submitBatchDataCallBack = nil;
   
}


-(void)submitPraiseWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];

        NSString *_uidM = requestInfo[@"userId"];
        NSString *_tp   = requestInfo[@"type"];
        
        if ([@"1" isEqualToString:_tp]) {
            
            NSString *_uid = @"";
            
            UserInfoEntity *_ue = [GloubleProperty sharedInstance].currentUserEntity;
            if (_ue) {
                _uid = [self inputStr:_ue.UI_userId];
            }
            DatabaseService *_dbs = [DatabaseService defaultDatabaseService];
            NSArray *_r = [_dbs getUserFriendListByUid:_uid
                                              memidatt:_uidM];
            if (_r && _r.count > 0) {
                FriendInfoEntity *_fe = _r[0];
                
                int _count = [[self inputStr:_fe.FI_countpraise] intValue];
                _count++;
                
                FriendInfoEntity *_fe2  = [[FriendInfoEntity alloc]init];
                _fe2.FI_mid             = [_fe.FI_mid copy];
                _fe2.FI_countpraise     = [NSString stringWithFormat:@"%d",_count];
                
                [_dbs updateFriend:_fe2];
            }
        }
        
        
        [self fillWebSuccessParam:_submitPraiseCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"submitPraise"];
        [self fillWebErrorParam:_submitPraiseCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"submitPraiseWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_submitPraiseCallBack errorObj:info[@"errorMsg"]];
   
        }else{
            
            [self showAlert:@"submitPraiseWithCode:发送请求失败"];
            [self fillWebErrorParam:_submitPraiseCallBack errorObj:info];

        }
        
        
    }
    
    _submitPraiseCallBack = nil;
}

-(void)queryPraiseWithCode:(int)code
                      info:(id)info
               requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        NSArray *_dataList = info[@"dataList"];
        
        
        if (_dataList) {
            NSMutableArray *_savePraiseList = [[NSMutableArray alloc]init];
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_praise   = _dataList[i];
                
                UserPraiseEntity *_upe  = [[UserPraiseEntity alloc]init];
                
                _upe.up_cname           = [self inputStr:_praise[@"cname"]] ;
                _upe.up_createtime      = [self inputStr:_praise[@"createtime"]] ;
                _upe.up_memid           = [self inputStr:_praise[@"memid"]] ;
                _upe.up_nickname        = [self inputStr:_praise[@"nickname"]] ;
                
                _upe.up_photopath       = [self inputStr:_praise[@"photopath"]] ;
                _upe.up_sex             = [self inputStr:_praise[@"sex"]] ;
                _upe.up_status          = [self inputStr:_praise[@"status"]] ;
                _upe.up_type            = [self inputStr:_praise[@"type"]] ;
                
                _upe.up_userId          = [self inputStr:requestInfo[@"userId"]] ;
                
                [_savePraiseList addObject:_upe];
                
            }
            
            

                [[DatabaseService defaultDatabaseService]savePariseUserList:_savePraiseList
                                                                        uid:[self inputStr:requestInfo[@"userId"]]];
         
            
            
            
        }
        
        
        NSArray *_ary = [[DatabaseService defaultDatabaseService]
                                    getPariseUserListbyUserId:[self inputStr:requestInfo[@"userId"]]
                                                         type:[self inputStr:requestInfo[@"type"]]];
        
        [self fillWebSuccessParam:_queryPraiseCallBack successObj:_ary];
    
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"queryPraise"];
        [self fillWebErrorParam:_queryPraiseCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"queryPraiseWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_queryPraiseCallBack errorObj:info[@"errorMsg"]];
            
            
        }else{

            [self showAlert:@"queryPraiseCallBack:发送请求失败"];
            [self fillWebErrorParam:_queryPraiseCallBack errorObj:info];

        }
        
        
    }
    
    _queryPraiseCallBack = nil;
}


-(void)queryFriendListWithCode:(int)code
                          info:(id)info
                   requestInfo:(id)requestInfo
{

    
    NSString *_tp = requestInfo[@"userInfo"];
    
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        NSArray *_dataList  = info[@"dataList"];
        
        if (_dataList) {
            NSMutableArray *_saveFriendList = [[NSMutableArray alloc]init];
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_friend   = _dataList[i];
                
                
                FriendInfoEntity *_se   = [[FriendInfoEntity alloc]init];
                
                _se.FI_userId           = [self inputStr:requestInfo[@"userId"]] ;
                _se.FI_weight           = [self inputStr:_friend[@"weight"]] ;
                _se.FI_status           = [self inputStr:_friend[@"status"]] ;
                _se.FI_sex              = [self inputStr:_friend[@"sex"]] ;
                
                _se.FI_photopath        = [self inputStr:_friend[@"photopath"]] ;
                _se.FI_nickName         = [self inputStr:_friend[@"nickName"]] ;
                _se.FI_mright_att       = [self inputStr:_friend[@"mright_att"]] ;
                _se.FI_mright           = [self inputStr:_friend[@"mright"]] ;
                
                _se.FI_mid              = [self inputStr:_friend[@"mid"]] ;
                _se.FI_memidatt         = [self inputStr:_friend[@"memidatt"]] ;
                _se.FI_loginId          = [self inputStr:_friend[@"loginId"]] ;
                _se.FI_isspeci          = [self inputStr:_friend[@"isspeci"]] ;
                
                _se.FI_isRead           = [self inputStr:_friend[@"isRead"]] ;
                _se.FI_ismutual         = [self inputStr:_friend[@"ismutual"]] ;
                _se.FI_insertTime       = [self inputStr:_friend[@"insertTime"]] ;
                _se.FI_fat              = [self inputStr:_friend[@"fat"]] ;
                
                _se.FI_countpraise      = [self inputStr:_friend[@"countpraise"]] ;
                _se.FI_cname            = [self inputStr:_friend[@"cname"]] ;
                _se.FI_checkdate        = [self inputStr:_friend[@"checkdate"]] ;
                _se.FI_bmi              = [self inputStr:_friend[@"bmi"]] ;
                
                _se.FI_birthday         = [self inputStr:_friend[@"birthday"]] ;
                _se.FI_age              = [self inputStr:_friend[@"age"]] ;

                
                [_saveFriendList addObject:_se];
                
            }
            
            [[DatabaseService defaultDatabaseService] saveFriendList:_saveFriendList
                                                              userId:[self inputStr:requestInfo[@"userId"]]];
 
        }
        
        if ([@"F" isEqualToString:_tp]) {
            NSArray *_result  = [[DatabaseService defaultDatabaseService]
                                 getUserFriendList:[self inputStr:requestInfo[@"userId"]]];
            [self fillWebSuccessParam:_queryFriendCallBack successObj:_result];
        }
        else if ([@"ARF" isEqualToString:_tp])
        {
            
            NSArray *_result  = [[DatabaseService defaultDatabaseService]
                                 getUserARFriendList:[self inputStr:requestInfo[@"userId"]]];
            
            [self fillWebSuccessParam:_queryARFriendCallBack successObj:_result];
        }
    
    }
    else if (code == kRequestNoLogin){
        [self reLogin:@"queryFriend"];
        [self fillWebErrorParam:_queryFriendCallBack errorObj:@"会话超时"];
        
        
        if ([@"F" isEqualToString:_tp]) {
            [self fillWebErrorParam:_queryFriendCallBack errorObj:@"会话超时"];
        }
        else if ([@"ARF" isEqualToString:_tp])
        {
            [self fillWebErrorParam:_queryARFriendCallBack errorObj:@"会话超时"];
        }
        
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"submitPraiseWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            
            if ([@"F" isEqualToString:_tp]) {
                [self fillWebErrorParam:_queryFriendCallBack errorObj:info[@"errorMsg"]];
            }
            else if ([@"ARF" isEqualToString:_tp])
            {
                [self fillWebErrorParam:_queryARFriendCallBack errorObj:info[@"errorMsg"]];
            }

        }else{
            
            
            [self showAlert:@"_queryFriendCallBack:发送请求失败"];

            
            if ([@"F" isEqualToString:_tp]) {
                [self fillWebErrorParam:_queryFriendCallBack errorObj:info];
            }
            else if ([@"ARF" isEqualToString:_tp])
            {
                [self fillWebErrorParam:_queryARFriendCallBack errorObj:info];
            }
            
        }
        
        
    }
    
    if ([@"F" isEqualToString:_tp]) {
        _queryFriendCallBack = nil;
    }
    else if ([@"ARF" isEqualToString:_tp])
    {
        _queryARFriendCallBack = nil;
    }
    
}

-(void)addFriendWithCode:(int)code
                    info:(id)info
             requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        
        [self fillWebSuccessParam:_addFriendWithFriendLonginNameCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"addFriend"];
        [self fillWebErrorParam:_addFriendWithFriendLonginNameCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"submitPraiseWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_addFriendWithFriendLonginNameCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"_addFriendWithFriendLonginNameCallBack:发送请求失败"];
            [self fillWebErrorParam:_addFriendWithFriendLonginNameCallBack errorObj:info];
            
        }
        
        
    }
    
    _addFriendWithFriendLonginNameCallBack = nil;
}

-(void)modifyFriendRightWithCode:(int)code
                            info:(id)info
                     requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        FriendInfoEntity *_fE = [[FriendInfoEntity alloc]init];
        _fE.FI_mid            = [self inputStr:requestInfo[@"mId"]] ;
        _fE.FI_mright_att     = [self inputStr:requestInfo[@"mRight"]];
        
        
        [[DatabaseService defaultDatabaseService]updateFriend:_fE];
        
        [self fillWebSuccessParam:_modifyFriendRightCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"modifyFriendRight"];
        [self fillWebErrorParam:_modifyFriendRightCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"_modifyFriendRight:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_modifyFriendRightCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"_modifyFriendRight:发送请求失败"];
            [self fillWebErrorParam:_modifyFriendRightCallBack errorObj:info];
            
        }
        
        
    }
    
    _modifyFriendRightCallBack = nil;
}

-(void)getUserSettingWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        UserInfoEntity *_user = [GloubleProperty sharedInstance].currentUserEntity;
        
        if (_user) {
            
            NSString *_privacy      = [self inputStr:info[@"privacy"]];
            NSString *_mode         = [self inputStr:info[@"mode"]];
            NSString *_plan         = [self inputStr:info[@"plan"]];
            NSString *_reCycle      = [self inputStr:info[@"remindcycle"]];
            NSString *_reMode       = [self inputStr:info[@"remindmode"]];
            
            _user.UI_privacy        = [@"" isEqualToString:_privacy]?@"1":_privacy;
            _user.UI_mode           = [@"" isEqualToString:_mode]?@"1":_mode;
            _user.UI_plan           = [@"" isEqualToString:_plan]?@"2":_plan;
            _user.UI_target         = [NSString stringWithFormat:@"%d",[[self inputStr:info[@"target"]] intValue]] ;
            _user.UI_remindcycle    = [@"" isEqualToString:_reCycle]?@"0":_reCycle;
            _user.UI_remindmode     = [@"" isEqualToString:_reMode]?@"0":_reMode;
            
            
            
            [[DatabaseService defaultDatabaseService] saveLoginUser:_user];
            
        }
        
        
        [self fillWebSuccessParam:_getUserSettingCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"getUserSetting"];
        [self fillWebErrorParam:_getUserSettingCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"_getUserSettingCallBack:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_getUserSettingCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"_getUserSettingCallBack:发送请求失败"];
            [self fillWebErrorParam:_getUserSettingCallBack errorObj:info];
            
        }
        
        
    }
    
    _getUserSettingCallBack = nil;
}

-(void)deleteFriendWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        NSString *_mid          = requestInfo[@"mId"];
        FriendInfoEntity *_fe   = [[FriendInfoEntity alloc]init];
        _fe.FI_mid              = _mid;
        
        [[DatabaseService defaultDatabaseService]deleteFriend:_fe];
        
        [self fillWebSuccessParam:_deleteFriendCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"deleteFriend"];
        [self fillWebErrorParam:_deleteFriendCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"deleteFriendWithWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_deleteFriendCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"deleteFriendWithWithCode:发送请求失败"];
            [self fillWebErrorParam:_deleteFriendCallBack errorObj:info];
            
        }
        
        
    }
    
    _deleteFriendCallBack = nil;
}

-(void)getMSGWithCode:(int)code
                 info:(id)info
          requestInfo:(id)requestInfo
{

    
    
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        NSArray *_dataList          = info[@"dataList"];
        NSNumber *_num              = @0;
        if (_dataList && _dataList.count > 0) {
            
            NSDictionary *_countDic = _dataList[0];
            if (_countDic && [_countDic isKindOfClass:[NSDictionary class]]) {

                
                _num = [NSNumber numberWithInt: [[self inputStr:_countDic[@"foucsMe"]] intValue]];
                
                
            }
            
            
        }
        
        [self fillWebSuccessParam:_getMSGCallBack successObj:_num];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"getMSG"];
        [self fillWebErrorParam:_getMSGCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"getMSGWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_getMSGCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getMSGWithCode:发送请求失败"];
            [self fillWebErrorParam:_getMSGCallBack errorObj:info];
            
        }
        
        
    }
    
    _getMSGCallBack = nil;
}

-(void)focusSetWithCode:(int)code
                   info:(id)info
            requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];

        
        [self fillWebSuccessParam:_focusSetCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"focusSet"];
        [self fillWebErrorParam:_focusSetCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"_focusSetCallBack:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_focusSetCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"_focusSetCallBack:发送请求失败"];
            [self fillWebErrorParam:_focusSetCallBack errorObj:info];
            
        }
        
        
    }
    
    _focusSetCallBack = nil;
}


-(void)getFocusMeListWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    NSLog(@"getFocusMeListWithCode-info:%@",info);
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        
        NSArray *_dataList          = info[@"dataList"];
        NSMutableArray *_saveList   = [[NSMutableArray alloc]init];
        if (_dataList) {
            
            for (int i = 0; i < _dataList.count ; i++)
            {
                
                NSDictionary *_obj   = _dataList[i];
                
                
                MSGFocusMeEntity *_se   = [[MSGFocusMeEntity alloc]init];

                _se.msgFm_loginId       = [self inputStr:_obj[@"loginId"]] ;
                _se.msgFm_userId        = [self inputStr:_obj[@"userId"]] ;
                _se.msgFm_status        = [self inputStr:_obj[@"status"]] ;
                _se.msgFm_sex           = [self inputStr:_obj[@"sex"]] ;
                
                _se.msgFm_photopath     = [self inputStr:_obj[@"photopath"]] ;
                _se.msgFm_nickName      = [self inputStr:_obj[@"nickName"]] ;
                _se.msgFm_myRight       = [self inputStr:_obj[@"myRight"]] ;
                _se.msgFm_mId           = [self inputStr:_obj[@"mId"]] ;
                
                _se.msgFm_isspeci       = [self inputStr:_obj[@"isspeci"]] ;
                _se.msgFm_isRead        = [self inputStr:_obj[@"isRead"]] ;
                _se.msgFm_ismutual      = [self inputStr:_obj[@"ismutual"]] ;
                _se.msgFm_createdate    = [self inputStr:_obj[@"createdate"]] ;
                
                _se.msgFm_cname         = [self inputStr:_obj[@"cname"]] ;
                _se.msgFm_age           = [self inputStr:_obj[@"age"]] ;

                
                
                [_saveList addObject:_se];
                
            }
  
        }
        
        [self fillWebSuccessParam:_getFocusMeListCallBack successObj:_saveList];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"getFocusMeList"];
        [self fillWebErrorParam:_getFocusMeListCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"getFocusMeListWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_getFocusMeListCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getFocusMeListWithCode:发送请求失败"];
            [self fillWebErrorParam:_getFocusMeListCallBack errorObj:info];
            
        }
        
        
    }
    
    _focusSetCallBack = nil;
}


-(void)setMsgReadedWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{

    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];

        
        [self fillWebSuccessParam:_setMsgReadedCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"setMsgReaded"];
        [self fillWebErrorParam:_setMsgReadedCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"getFocusMeListWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_setMsgReadedCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getFocusMeListWithCode:发送请求失败"];
            [self fillWebErrorParam:_setMsgReadedCallBack errorObj:info];
            
        }
        
        
    }
    
    _setMsgReadedCallBack = nil;
}


-(void)delMsgWithCode:(int)code
                 info:(id)info
          requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        
        [self fillWebSuccessParam:_delMsgCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"delMsg"];
        [self fillWebErrorParam:_delMsgCallBack errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"delMsgWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_delMsgCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getFocusMeListWithCode:发送请求失败"];
            [self fillWebErrorParam:_delMsgCallBack errorObj:info];
            
        }
        
        
    }
    
    _delMsgCallBack = nil;
}


-(void)deleteDataWithCode:(int)code
                     info:(id)info
              requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        _loginDate = [NSDate date];
        
        NSNumber *_did = requestInfo[@"dataId"];
        
        
        [[DatabaseService defaultDatabaseService]deleteDataByDid:[self inputStr:_did]];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kIMDataChanged
                                                           object:nil
                                                         userInfo:nil];
        
        [self fillWebSuccessParam:_deleteDataCallback successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self reLogin:@"delMsg"];
        [self fillWebErrorParam:_deleteDataCallback errorObj:@"会话超时"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"delMsgWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_deleteDataCallback errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getFocusMeListWithCode:发送请求失败"];
            [self fillWebErrorParam:_deleteDataCallback errorObj:info];
            
        }
        
        
    }
    
    _deleteDataCallback = nil;
}

-(void)checkCodeInvalidWithCode:(int)code
                           info:(id)info
                    requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {

        
        [self fillWebSuccessParam:_checkCodeInvalidCallBack successObj:nil];
        
        
    }
    else if (code == kRequestNoLogin)
    {
        [self fillWebErrorParam:_checkCodeInvalidCallBack errorObj:@"服务器异常"];
    }
    else { // 包括网络请求错误 以及请求参数错误
        if ([info isKindOfClass:[NSDictionary class]]) {
            
            [self showAlert:[NSString stringWithFormat:@"delMsgWithCode:%@",
                             [self inputStr:info[@"errorMsg"]]]];
            
            [self fillWebErrorParam:_checkCodeInvalidCallBack errorObj:info[@"errorMsg"]];
            
        }else{
            
            
            [self showAlert:@"getFocusMeListWithCode:发送请求失败"];
            [self fillWebErrorParam:_checkCodeInvalidCallBack errorObj:info];
            
        }
        
        
    }
    
    _checkCodeInvalidCallBack = nil;
}

-(void)getDevColorWithCode:(int)code
                      info:(id)info
               requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {
        if (_getDevColorCallback) {
            NSString *_clr = info[@"color"];
            DevColor _color = DevColorFaile;
            if ([@"0" isEqualToString:_clr]) {
                _color = DevColorWhite;
            }
            else if ([@"1" isEqualToString:_clr]) {
                _color = DevColorBlack;
            }
            else if ([@"2" isEqualToString:_clr]) {
                _color = DevColorRed;
            }
            else if ([@"3" isEqualToString:_clr]) {
                _color = DevColorGreen;
            }
            else if ([@"4" isEqualToString:_clr]) {
                _color = DevColorYellow;
            }
            
            if (_getDevColorCallback) {
                _getDevColorCallback(WebCallBackResultSuccess,_color,nil);
            }
            
        }
    }
    else
    {
        if (_getDevColorCallback) {
            _getDevColorCallback(WebCallBackResultFailure,DevColorFaile,@"获取失败");
        }
    }
    
    
    _getDevColorCallback = nil;
}

-(void)checkLoginNameWithCode:(int)code
                         info:(id)info
                  requestInfo:(id)requestInfo
{
    
    if (code == REQUEST_SUCCESS_CODE) {


        BOOL _flag = NO;
        
        if ([@"1" isEqualToString:[self inputStr:info[@"ishas"]]]) {
            _flag = YES;
        }
        
        if (_checkLoginNameCallBack) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _checkLoginNameCallBack(WebCallBackResultSuccess,_flag,nil);
                _checkLoginNameCallBack = nil;
            });
            
        }

    }
    else
    {
        if (_checkLoginNameCallBack) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _checkLoginNameCallBack(WebCallBackResultSuccess,NO,@"获取失败");
                _checkLoginNameCallBack = nil;
            });
            
        }
    }
    
    
    
}



#pragma mark - 购买相关请求
-(void)getProductInfoWithCode:(int)code
                             info:(id)info
                      requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {

        NSString *_codeNum = [self inputStr:info[@"code"]] ;
        if ([_codeNum intValue] == 1) {
            NSArray *_externalProductList = info[@"externalProductList"];
            if (_externalProductList &&
                [_externalProductList isKindOfClass:[NSArray class]])
            {
                NSMutableArray *_productList = [[NSMutableArray alloc]init];
                for (int i= 0; i < _externalProductList.count; i++) {
                    NSDictionary *_dic = _externalProductList[i];
                    if (_dic &&
                        [_dic isKindOfClass:[NSDictionary class]])
                    {
                        [_productList addObject:[BR_ProductEntity createProduct:_dic]];
                    }
                }
                
                [self fillWebSuccessParam:_getProductInfoCallback successObj:_productList];
            }
            else
            {
                [self fillWebErrorParam:_getProductInfoCallback errorObj:@"数据异常，加载失败"];
            }
        }
        else
        {
            [self fillWebErrorParam:_getProductInfoCallback errorObj:@"数据异常，加载失败"];
        }
  
    }
    else { // 包括网络请求错误 以及请求参数错误
        
        [self fillWebErrorParam:_getProductInfoCallback errorObj:info];
      
    }
    
    _getProductInfoCallback = nil;
}


-(void)getOrderWithWithCode:(int)code
                       info:(id)info
                requestInfo:(id)requestInfo
{
    if (code == REQUEST_SUCCESS_CODE) {

        [self fillWebSuccessParam:_getOrderInfoCallback successObj:info];

    }
    else { // 包括网络请求错误 以及请求参数错误
        
        [self fillWebErrorParam:_getOrderInfoCallback errorObj:info];
        
    }
    
    _getOrderInfoCallback = nil;
}





#pragma mark- 第三方登录

-(void)jingDongLoginWithCode:(int)code
                        info:(id)info
                 requestInfo:(id)requestInfo
{
    NSLog(@"#########################");
    NSLog(@"requestInfo:%@",requestInfo);
    NSLog(@"info:%@",info);
    
    switch (code) {
        case ThirdSide_REQUEST_SUCCESS_CODE:
        {
            
            if (info) {
                NSString *_sessionId    = [self inputStr:info[@"sessionId"]] ;
                NSString *_userId       = [self inputStr:info[@"userId"]] ;
                NSString *_loginName    = [self inputStr:info[@"loginName"]];
                NSString *_age          = [self inputStr:info[@"age"]] ;
                NSString *_sex          = [self inputStr:info[@"sex"]] ;
                
                [self showAlert:info[@"msg"]];
                _tempSid = _sessionId;
                UserInfoEntity *_userInfo = nil;
                if ([@"0" isEqualToString:_age] &&
                    [@"2" isEqualToString:_sex]
                ) {
                    _userInfo               = [[UserInfoEntity alloc]init];
                    _userInfo.UI_nickname   = _tempJDUser.user_nick;
                    _userInfo.UI_userId     = _userId;
                    _userInfo.UI_loginName  = _loginName;
                    _userInfo.UI_loginPwd   = @"";
                    _userInfo.UI_isLoc      = @"3";
                    
                    [[DatabaseService defaultDatabaseService]saveLoginUser:_userInfo];
                    
                    if (_jdLonginCallback) {
                        _jdLonginCallback(ThirdSideLoginResult_agereeNoReg,
                                            _userInfo,
                                            nil);
                    }
                }
                else{
                    
                    _userInfo = [[DatabaseService defaultDatabaseService]getUserByUid:_userId];
                    
                    if (_userInfo) {
                        _userInfo.UI_nickname   = _tempJDUser.user_nick;
                        _userInfo.UI_age        = _age;
                        _userInfo.UI_sex        = _sex;
                        _userInfo.UI_isLoc      = @"3";
                    }
                    else{
                        _userInfo               = [[UserInfoEntity alloc]init];
                        _userInfo.UI_nickname   = _tempJDUser.user_nick;
                        _userInfo.UI_userId     = _userId;
                        _userInfo.UI_loginName  = _loginName;
                        _userInfo.UI_loginPwd   = @"";
                        _userInfo.UI_age        = _age;
                        _userInfo.UI_sex        = _sex;
                        _userInfo.UI_isLoc      = @"3";
                    }
                    [[DatabaseService defaultDatabaseService]saveLoginUser:_userInfo];
                    
                    if (_jdLonginCallback) {
                        _jdLonginCallback(ThirdSideLoginResult_agereeReg,
                                          _userInfo,
                                          nil);
                    }
                }
            }
        }
            break;
        case REQUEST_FAILURE_CODE:
        {
            if (_jdLonginCallback) {
                _jdLonginCallback(ThirdSideLoginResult_refuse,nil,@"网络异常，登陆失败");
            }
        }
            break;
        default:
        {
            if (_jdLonginCallback) {
                _jdLonginCallback(ThirdSideLoginResult_refuse,nil,[self inputStr:info[@"msg"]]);
            }
        }
            break;
    }
    
    
    
    _jdLonginCallback = nil;
}







@end