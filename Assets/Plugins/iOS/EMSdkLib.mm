//
//  EMSdkLib.m
//  easemob
//
//  Created by lzj on 13/11/2016.
//  Copyright © 2016 EaseMob. All rights reserved.
//

#import "EMSdkLib.h"

@implementation EMSdkLib

static NSString* EM_U3D_OBJECT = @"emsdk_cb_object";


+ (instancetype) sharedSdkLib
{
    static EMSdkLib *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[EMSdkLib alloc] init];
        // Do any other initialisation stuff here
        
    });
    
    return sharedInstance;
}

- (void) initializeSDK:(NSString *)appKey
{
    EMOptions *options = [EMOptions optionsWithAppkey:appKey];
//    options.apnsCertName = @"istore_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (int) createAccount:(NSString *)username withPwd:(NSString *)password
{
    EMError *error = [[EMClient sharedClient] registerWithUsername:username password:password];
    if(!error)
        return 0;
    else
        return [error code];
}

- (void) login:(NSString *)username withPwd:(NSString *)password
{
    [[EMClient sharedClient] loginWithUsername:username password:password completion:^(NSString *username, EMError *error){
        NSString *cbName = @"LoginCallback";
        if(!error){
            [self sendSuccessCallback:cbName];
        }else{
            [self sendErrorCallback:cbName withError:error];
        }
    }];
}

- (void) logout:(BOOL)flag
{
    [[EMClient sharedClient] logout:flag completion:^(EMError *error){
        NSString *cbName = @"LogoutCallback";
        if(!error)
        {
            [self sendSuccessCallback:cbName];
        }else{
            [self sendErrorCallback:cbName withError:error];
        }
    
    }];
}

- (void) sendTextMessage:(NSString *)content toUser:(NSString *)to callbackId:(int)callbackId chattype:(int)chattype ext:(NSString*) ext
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:content];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    EMMessage *message = nil;
    if ([ext length] > 0) {
        NSDictionary *dic =[NSDictionary dictionaryWithObject:ext forKey:@"extkey"];
        message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:dic];
    } else {
        message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    }

    if(chattype == 0)
        message.chatType = EMChatTypeChat;// 设置为单聊消息
    else if (chattype == 1)
        message.chatType = EMChatTypeGroupChat;
    
    [self sendMessage:message CallbackId:callbackId];
}

- (void) sendFileMessage:(NSString *)path toUser:(NSString *)to callbackId:(int)callbackId chattype:(int)chattype ext:(NSString*) ext
{
    EMFileMessageBody *body = [[EMFileMessageBody alloc] initWithLocalPath:path displayName:[path lastPathComponent]];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    EMMessage *message = nil;
    if ([ext length] > 0) {
        NSDictionary *dic =[NSDictionary dictionaryWithObject:ext forKey:@"extkey"];
        message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:dic];
    } else {
        message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:nil];
    }

    if(chattype == 0)
        message.chatType = EMChatTypeChat;// 设置为单聊消息
    else if (chattype == 1)
        message.chatType = EMChatTypeGroupChat;
    
    [self sendMessage:message CallbackId:callbackId];
}

- (NSString *) getAllContactsFromServer
{
//    EMError *error = nil;
//    NSArray *array = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
//    if(!error && [array count] > 0)
//        return [array componentsJoinedByString:@","];
    return @"";
}

- (NSString *) getAllConversations
{
    NSMutableArray *retArray = [NSMutableArray array];
    NSArray *array = [[EMClient sharedClient].chatManager getAllConversations];
    if([array count] >0)
        for(EMConversation *con in array){
            [retArray addObject:[self conversation2dic:con]];
        }
    return [self toJson:retArray];
}

- (NSString *) getAllConversationMessage:(NSString *)fromUser
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:fromUser type:EMConversationTypeChat createIfNotExist:YES];
    EMMessage *latestMsg = [conversation latestMessage];
    if(latestMsg != nil){
        return [self loadMessagesStartFromId:latestMsg.messageId fromUser:fromUser pageSize:20];
    }
    return [self toJson:[NSArray array]];
}

- (NSString *) getLatestMessage:(NSString *)fromUser
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:fromUser type:EMConversationTypeChat createIfNotExist:YES];
    EMMessage *latestMsg = [conversation latestMessage];
    if(latestMsg != nil)
        return [self toJson:[self message2dic:latestMsg]];
    return @"";
}

- (NSString *) loadMessagesStartFromId:(NSString *)msgId fromUser:(NSString *)username pageSize:(int)size
{
//    EMConversation *conversation =  [[EMClient sharedClient].chatManager getConversation:username type:EMConversationTypeChat createIfNotExist:YES];
//    NSArray *messages = [conversation loadMoreMessagesFromId:msgId limit:size direction:EMMessageSearchDirectionUp];
    NSMutableArray *retArray = [NSMutableArray array];
//    if([messages count] > 0){
//        for (EMMessage *msg in messages){
//            [retArray addObject:[self message2dic:msg]];
//        }
//    }
    return [self toJson:retArray];
}

- (void) createGroup:(NSString *)groupName desc:(NSString *)desc members:(NSString *)ms reason:(NSString *)reason maxUsers:(int)count type:(int)type callbackId:(int)cbId
{
    NSString *cbName = @"CreateGroupCallback";
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = count;
    setting.style = (EMGroupStyle)type;
    NSArray *arr = [ms componentsSeparatedByString:@","];
    [[EMClient sharedClient].groupManager createGroupWithSubject:groupName description:desc invitees:arr message:reason setting:setting completion:^(EMGroup *group, EMError *error){
        if(group && !error){
            NSString *json = [self toJson:[self group2dic:group]];
            [self sendSuccessCallback:cbName CallbackId:cbId data:json];
        }else{
            [self sendErrorCallback:cbName CallbackId:cbId  withError:error];
        }
        
    }];
}

- (NSString *)getGroup:(NSString *)groupId
{
    EMError *error = nil;
    EMGroup *group = [[EMClient sharedClient].groupManager fetchGroupInfo:groupId includeMembersList:YES error:&error];
    if(!error)
    {
        return [self toJson:[self group2dic:group]];
    }
    return @"";
}

- (void)getJoinedGroupsFromServer:(int)cbId
{
    NSString *cbName = @"GetJoinedGroupsFromServerCallback";

    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError && [aList count] > 0) {
            NSMutableArray *array = [NSMutableArray array];
            for (EMGroup *group in aList) {
                [array addObject:[self group2dic:group]];
            }
            [self sendSuccessCallback:cbName CallbackId:cbId data:[self toJson:array]];
        } else if (aError){
            [self sendErrorCallback:cbName CallbackId:cbId withError:aError];
        }
    }];
}

- (void) addMembers:(NSString *)ms toGroup: (NSString *) aGroupId withMessage:(NSString *)message callbackId:(int) cbId
{
    NSString *cbName = @"AddUsersToGroupCallback";
    NSArray *members = [ms componentsSeparatedByString:@","];
    [[EMClient sharedClient].groupManager addMembers:members toGroup:aGroupId message:message completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            [self sendSuccessCallback:cbName CallbackId: cbId];
        }
        else if (aError){
            [self sendErrorCallback:cbName CallbackId:cbId withError:aError];
        }
    }];
}

- (int) getUnreadMsgCount:(NSString *)fromUser
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:fromUser type:EMConversationTypeChat createIfNotExist:YES];
    return conversation.unreadMessagesCount;
}

- (void) markAllMessagesAsRead:(NSString *)fromUser
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:fromUser type:EMConversationTypeChat createIfNotExist:YES];
    [conversation markAllMessagesAsRead:nil];
}

- (BOOL) deleteConversation:(NSString *)fromUser delHistory:(BOOL)flag
{
    [[EMClient sharedClient].chatManager deleteConversation:fromUser isDeleteMessages:flag completion:nil];
    return YES;
}

- (void) removeMessage:(NSString *)fromUser messageId:(NSString *)msgId
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:fromUser type:EMConversationTypeChat createIfNotExist:YES];
    [conversation deleteMessageWithId:msgId error:nil];
}

- (void) joinGroup:(NSString *)aGroupId callbackId:(int) cbId
{
    NSString *cbName = @"JoinGroupCallback";
    [[EMClient sharedClient].groupManager joinPublicGroup:aGroupId completion:^(EMGroup *group, EMError *error){
        if(!error)
            [self sendSuccessCallback:cbName CallbackId: cbId];
        else
            [self sendErrorCallback:cbName CallbackId:cbId withError:error];
    }];
}

- (void) leaveGroup:(NSString *)aGroupId callbackId:(int) cbId
{
    NSString *cbName = @"LeaveGroupCallback";
    [[EMClient sharedClient].groupManager leaveGroup:aGroupId completion:^(EMGroup *aGroup, EMError *aError) {
        if (!aError) {
            [self sendSuccessCallback:cbName CallbackId: cbId];
        }
        else if (aError){
            [self sendErrorCallback:cbName CallbackId:cbId withError:aError];
        }
    }];
}

//connection delegates
- (void)connectionStateDidChange:(EMConnectionState)aConnectionState
{
    if (aConnectionState == EMConnectionConnected)
        [self sendCallback:@"ConnectedCallback" param:@""];
    else
        [self sendCallback:@"DisconnectedCallback" param:@""];
}


//message delegates
- (void)messagesDidReceive:(NSArray *)aMessages
{
    NSMutableArray *array = [NSMutableArray array];
    for(EMMessage *message in aMessages)
    {
        [array addObject:[self message2dic:message]];
    }
    
    NSString *json = [self toJson:array];
    if(json != nil)
    {
        [self sendCallback:@"MessageReceivedCallback" param:json];
    }
}

- (void)messagesDidRead:(NSArray *)aMessages
{
    NSMutableArray *array = [NSMutableArray array];
    for(EMMessage *message in aMessages)
    {
        [array addObject:[self message2dic:message]];
    }
    
    NSString *json = [self toJson:array];
    if(json != nil)
    {
        [self sendCallback:@"MessageReadAckReceivedCallback" param:json];
    }
}

- (void)messagesDidDeliver:(NSArray *)aMessages
{
    NSMutableArray *array = [NSMutableArray array];
    for(EMMessage *message in aMessages)
    {
        [array addObject:[self message2dic:message]];
    }
    
    NSString *json = [self toJson:array];
    if(json != nil)
    {
        [self sendCallback:@"MessageDeliveryAckReceivedCallback" param:json];
    }
}


//group delegates
- (void)groupInvitationDidReceive:(NSString *)aGroupId inviter:(NSString *)aInviter message:(NSString *)aMessage
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroupId forKey:@"groupId"];
    [dic setObject:@"" forKey:@"groupName"];
    [dic setObject:aInviter forKey:@"inviter"];
    [dic setObject:aMessage forKey:@"reason"];
    [self sendCallback:@"InvitationReceivedCallback" param:[self toJson:dic]];
}

- (void)groupInvitationDidAccept:(EMGroup *)aGroup invitee:(NSString *)aInvitee
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aInvitee forKey:@"inviter"];
    [dic setObject:@"" forKey:@"reason"];
    [self sendCallback:@"InvitationAcceptedCallback" param:[self toJson:dic]];
}

- (void)groupInvitationDidDecline:(EMGroup *)aGroup invitee:(NSString *)aInvitee reason:(NSString *)aReason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aInvitee forKey:@"inviter"];
    [dic setObject:aReason forKey:@"reason"];
    [self sendCallback:@"InvitationDeclinedCallback" param:[self toJson:dic]];
}

- (void)didJoinGroup:(EMGroup *)aGroup inviter:(NSString *)aInviter message:(NSString *)aMessage
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aInviter forKey:@"inviter"];
    [dic setObject:aMessage forKey:@"inviteMessage"];
    [self sendCallback:@"AutoAcceptInvitationFromGroupCallback" param:[self toJson:dic]];
}

- (void)didLeaveGroup:(EMGroup *)aGroup reason:(EMGroupLeaveReason)aReason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aGroup.subject forKey:@"groupName"];
    [self sendCallback:@"UserRemovedCallback" param:[self toJson:dic]];
}

- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup user:(NSString *)aUsername reason:(NSString *)aReason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aGroup.subject forKey:@"groupName"];
    [dic setObject:aUsername forKey:@"applicant"];
    [dic setObject:aReason forKey:@"reason"];
    [self sendCallback:@"ApplicationReceivedCallback" param:[self toJson:dic]];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId reason:(NSString *)aReason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroupId forKey:@"groupId"];
    [dic setObject:@"" forKey:@"groupName"];
    [dic setObject:@"" forKey:@"decliner"];
    [dic setObject:aReason forKey:@"reason"];
    [self sendCallback:@"ApplicationDeclinedCallback" param:[self toJson:dic]];
}

- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:aGroup.groupId forKey:@"groupId"];
    [dic setObject:aGroup.subject forKey:@"groupName"];
    [dic setObject:@"" forKey:@"accepter"];
    [self sendCallback:@"ApplicationAcceptCallback" param:[self toJson:dic]];
}

- (void)groupListDidUpdate:(NSArray *)aGroupList
{
    
}

- (void)downloadAttachmentFrom:(NSString *)username messageId:(NSString *)msgId callbackId:(int)cbId
{
    NSString *cbName = @"DownloadAttachmentCallback";
    
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:username type:EMConversationTypeGroupChat createIfNotExist:YES];
    EMMessage *message = [conversation loadMessageWithId:msgId error:nil];
    [[EMClient sharedClient].chatManager downloadMessageAttachment:(EMMessage *)message
                                                          progress:^(int progress){
                                                              [self sendInProgressCallback:cbName CallbackId:cbId Progress:progress];
                                                          }
                                                        completion:^(EMMessage *message, EMError *error){
                                                            if(error)
                                                                [self sendErrorCallback:cbName CallbackId:cbId withError:error];
                                                            else
                                                                [self sendSuccessCallback:cbName CallbackId:cbId];
                                                        }];
}

- (NSString *)getConversation:(NSString *)cid type:(int)type createIfNotExists:(BOOL)createIfNotExists
{
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:cid type:(EMConversationType)type createIfNotExist:createIfNotExists];
    return [self toJson:[self conversation2dic:conversation]];
}

- (void) deleteMessagesAsExitGroup:(BOOL)del
{
    [EMClient sharedClient].options.isDeleteMessagesWhenExitGroup = del;
}

- (void) isAutoAcceptGroupInvitation:(BOOL)isAuto
{
    [EMClient sharedClient].options.isAutoAcceptGroupInvitation = isAuto;
}

- (void) isSortMessageByServerTime:(BOOL)isSort
{
    [EMClient sharedClient].options.sortMessageByServerTime = isSort;
}

- (void) requireDeliveryAck:(BOOL)isReq
{
    [EMClient sharedClient].options.enableDeliveryAck = isReq;
}

- (void) sendMessage:(EMMessage *)message CallbackId:(int)callbackId
{
    NSString *cbName = @"SendMessageCallback";
    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress){
        [self sendInProgressCallback:cbName CallbackId:callbackId Progress:progress];
    } completion:^(EMMessage *message, EMError *error){
        if(error)
            [self sendErrorCallback:cbName CallbackId:callbackId withError:error];
        else
            [self sendSuccessCallback:cbName CallbackId:callbackId];
    }];
}

- (void) sendSuccessCallback:(NSString *)cbName
{
    [self sendCallback:EM_U3D_OBJECT cbName:cbName param:@"{\"on\":\"success\"}"];
}

- (void) sendSuccessCallback:(NSString *)cbName CallbackId:(int) callbackId
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"success" forKey:@"on"];
    [dic setObject:[NSNumber numberWithInt:callbackId] forKey:@"callbackid"];
    NSString *json = [self toJson:dic];
    if(json != nil)
        [self sendCallback:EM_U3D_OBJECT cbName:cbName param:json];
}

- (void) sendSuccessCallback:(NSString *)cbName CallbackId:(int) callbackId data:(NSString *)jsonData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"success" forKey:@"on"];
    [dic setObject:[NSNumber numberWithInt:callbackId] forKey:@"callbackid"];
    [dic setObject:jsonData forKey:@"data"];
    NSString *json = [self toJson:dic];
    if(json != nil)
        [self sendCallback:EM_U3D_OBJECT cbName:cbName param:json];
}

- (void) sendErrorCallback:(NSString *)cbName withError:(EMError *)error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"error" forKey:@"on"];
    [dic setObject:[NSNumber numberWithInt:[error code]]  forKey:@"code"];
    [dic setObject:[error errorDescription] forKey:@"message"];
    NSString *json = [self toJson:dic];
    if(json != nil){
        [self sendCallback:EM_U3D_OBJECT cbName:cbName param:json];
    }
}
- (void) sendErrorCallback:(NSString *)cbName CallbackId:(int) callbackId withError:(EMError *)error
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"error" forKey:@"on"];
    [dic setObject:[NSNumber numberWithInt:callbackId] forKey:@"callbackid"];
    [dic setObject:[NSNumber numberWithInt:[error code]]  forKey:@"code"];
    [dic setObject:[error errorDescription] forKey:@"message"];
    NSString *json = [self toJson:dic];
    if(json != nil){
        [self sendCallback:EM_U3D_OBJECT cbName:cbName param:json];
    }
}

- (void) sendInProgressCallback:(NSString *)cbName CallbackId:(int) callbackId Progress:(int)progress
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"progress" forKey:@"on"];
    [dic setObject:[NSNumber numberWithInt:callbackId] forKey:@"callbackid"];
    [dic setObject:[NSNumber numberWithInt:progress]  forKey:@"progress"];
    [dic setObject:@"status" forKey:@"status"];
    NSString *json = [self toJson:dic];
    if(json != nil){
        [self sendCallback:EM_U3D_OBJECT cbName:cbName param:json];
    }
}

- (void) sendCallback:(NSString *)objName cbName:(NSString *)cbName param:(NSString *)jsonParam
{
    NSLog(@"Send to objName=%@, cbName=%@, param=%@",objName,cbName,jsonParam);
    UnitySendMessage([objName UTF8String], [cbName UTF8String], [jsonParam UTF8String]);
}

- (void)sendCallback:(NSString *)cbName param:(NSString *)jsonParam
{
    [self sendCallback:EM_U3D_OBJECT cbName:cbName param:jsonParam];
}

- (NSString *)toJson:(id)ocData
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:ocData options:0 error:&error];
    if(!error){
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}
- (NSDictionary *)json2Dic:(NSString *)jsonStr
{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSDictionary *) message2dic:(EMMessage *)message
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:message.messageId forKey:@"mMsgId"];
    [dic setObject:message.from forKey:@"mFrom"];
    [dic setObject:message.to forKey:@"mTo"];
    [dic setObject:message.isRead?@"true":@"false" forKey:@"mIsUnread"];
    [dic setObject:@"false" forKey:@"mIsListened"];//TODO
    [dic setObject:message.isReadAcked?@"true":@"false" forKey:@"mIsAcked"];
    [dic setObject:message.isDeliverAcked?@"true":@"false" forKey:@"mIsDelivered"];
    [dic setObject:[NSNumber numberWithLong:message.localTime] forKey:@"mLocalTime"];
    [dic setObject:[NSNumber numberWithLong:message.timestamp] forKey:@"mServerTime"];
    [dic setObject:[NSNumber numberWithInt:(message.body.type-1)] forKey:@"mType"];
    [dic setObject:[NSNumber numberWithInt:message.status] forKey:@"mStatus"];
    [dic setObject:[NSNumber numberWithInt:message.direction] forKey:@"mDirection"];
    [dic setObject:[NSNumber numberWithInt:message.chatType] forKey:@"mChatType"];
    if(message.ext != nil && [message.ext objectForKey:@"extkey"] != nil)
        [dic setObject:[message.ext objectForKey:@"extkey"] forKey:@"mExtJsonStr"];
    
    if (message.body.type == EMMessageBodyTypeFile){
        EMFileMessageBody *body = (EMFileMessageBody *)message.body;
        [dic setObject:body.displayName forKey:@"mDisplayName"];
        [dic setObject:body.secretKey forKey:@"mSecretKey"];
        [dic setObject:body.localPath forKey:@"mLocalPath"];
        [dic setObject:body.remotePath forKey:@"mRemotePath"];
    }
    if(message.body.type == EMMessageBodyTypeText)
    {
        EMTextMessageBody *textBody = (EMTextMessageBody *)message.body;
        [dic setObject:textBody.text forKey:@"mTxt"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

- (NSDictionary *) group2dic:(EMGroup *)group
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:group.groupId forKey:@"mGroupId"];
    [dic setObject:group.subject forKey:@"mGroupName"];
    [dic setObject:group.description forKey:@"mDescription"];
    [dic setObject:group.owner forKey:@"mOwner"];
    [dic setObject:[NSNumber numberWithInteger:group.membersCount] forKey:@"mMemCount"];
    if([group.members count] > 0)
        [dic setObject:[group.members componentsJoinedByString:@","] forKey:@"mMembers"];
    else
        [dic setObject:@"" forKey:@"mMembers"];
    [dic setObject:group.isPublic?@"true":@"false" forKey:@"mIsPublic"];
    [dic setObject:group.isBlocked?@"true":@"false" forKey:@"mIsMsgBlocked"];
    if(group.setting.style == EMGroupStylePrivateMemberCanInvite)
        [dic setObject:@"true" forKey:@"mIsAllowInvites"];
    else
        [dic setObject:@"false" forKey:@"mIsAllowInvites"];
    if(group.setting.style == EMGroupStylePublicOpenJoin)
        [dic setObject:@"false" forKey:@"mIsNeedApproval"];
    else
        [dic setObject:@"true" forKey:@"mIsNeedApproval"];

    return [NSDictionary dictionaryWithDictionary:dic];
}

- (NSDictionary *) conversation2dic:(EMConversation *)conversation
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:conversation.conversationId forKey:@"mConversationId"];
    [dic setObject:[NSNumber numberWithInt:conversation.type] forKey:@"mConversationType"];
    [dic setObject:[NSNumber numberWithInt:conversation.unreadMessagesCount] forKey:@"mUnreadMsgCount"];
    if(conversation.ext != nil)
        [dic setObject:[self toJson:conversation.ext] forKey:@"mExt"];
    else
        [dic setObject:@"" forKey:@"mExt"];
    if(conversation.latestMessage != nil)
    {
        NSString *msg = [self toJson:[self message2dic:conversation.latestMessage]];
        [dic setObject:msg forKey:@"mLatesMsg"];
    }else
        [dic setObject:[self toJson:[NSDictionary dictionary]] forKey:@"mLatesMsg"];
    return [NSDictionary dictionaryWithDictionary:dic];
}

@end

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return [NSString stringWithUTF8String: ""];
}
// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

extern "C" {
    
    int _createAccount(const char* username, const char*password)
    {
        return [[EMSdkLib sharedSdkLib] createAccount:CreateNSString(username) withPwd:CreateNSString(password)];
    }

    void _login(const char* username, const char* password)
    {
        [[EMSdkLib sharedSdkLib] login:CreateNSString(username) withPwd:CreateNSString(password)];
    }

    void _logout(bool flag)
    {
        [[EMSdkLib sharedSdkLib] logout:flag];
    }

    void _sendTextMessage(const char* content, const char* to, int callbackId,int chattype, const char* ext)
    {
        [[EMSdkLib sharedSdkLib] sendTextMessage:CreateNSString(content) toUser:CreateNSString(to) callbackId:callbackId chattype:chattype ext:CreateNSString(ext)];
    }

    void _sendFileMessage(const char* path, const char* to, int callbackId,int chattype, const char* ext)
    {
        [[EMSdkLib sharedSdkLib] sendFileMessage:CreateNSString(path) toUser:CreateNSString(to) callbackId:callbackId chattype:chattype ext:CreateNSString(ext)];
    }
    
    const char* _getAllContactsFromServer()
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getAllContactsFromServer] UTF8String]);
    }
    
    const char* _getAllConversations()
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getAllConversations] UTF8String]);
    }
    
    const char* _getAllConversationMessage(const char* username)
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getAllConversationMessage:CreateNSString(username)] UTF8String]);
    }
    
    const char* _getConversationMessage(const char* username, const char* startMsgId, int pageSize)
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] loadMessagesStartFromId:CreateNSString(startMsgId) fromUser:CreateNSString(username) pageSize:pageSize] UTF8String]) ;
    }
    
    const char* _getLatestMessage(const char* username)
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getLatestMessage:CreateNSString(username)] UTF8String]);
    }
    
    int _getUnreadMsgCount(const char* username)
    {
        return [[EMSdkLib sharedSdkLib] getUnreadMsgCount:CreateNSString(username)];
    }
    
    void _markAllMessagesAsRead(const char* username)
    {
        [[EMSdkLib sharedSdkLib] markAllMessagesAsRead:CreateNSString(username)];
    }
    
    BOOL _deleteConversation (const char* username, bool isDeleteHistory)
    {
        return [[EMSdkLib sharedSdkLib] deleteConversation:CreateNSString(username) delHistory:isDeleteHistory];
    }
    
    void _removeMessage (const char* username, const char* msgId)
    {
        return [[EMSdkLib sharedSdkLib] removeMessage:CreateNSString(username) messageId:CreateNSString(msgId)];
    }
    
    void _createGroup (int callbackId, const char* groupName, const char* desc, const char* strMembers, const char* reason, int maxUsers, int style)
    {
        [[EMSdkLib sharedSdkLib] createGroup:CreateNSString(groupName) desc:CreateNSString(desc) members:CreateNSString(strMembers) reason:CreateNSString(reason) maxUsers:maxUsers type:style callbackId:callbackId];
    }

    const char* _getGroup(const char* groupId)
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getGroup:CreateNSString(groupId)] UTF8String]);
    }
    
    void _getJoinedGroupsFromServer(int callbackId)
    {
        [[EMSdkLib sharedSdkLib] getJoinedGroupsFromServer:callbackId];
    }
    
    void _addUsersToGroup(int callbackId, const char* toGroup, const char* members)
    {
        [[EMSdkLib sharedSdkLib] addMembers:CreateNSString(members) toGroup:CreateNSString(toGroup) withMessage:@"Hi" callbackId:callbackId];
    }
    
    void _inviteUser (int callbackId,const char* groupId, const char* beInvitedUsernames, const char* reason)
    {
        [[EMSdkLib sharedSdkLib] addMembers:CreateNSString(beInvitedUsernames) toGroup:CreateNSString(groupId) withMessage:CreateNSString(reason) callbackId:callbackId];
    }
    
    void _joinGroup (int callbackId,const char* groupId)
    {
        [[EMSdkLib sharedSdkLib] joinGroup:CreateNSString(groupId) callbackId:callbackId];
    }
    
    void _leaveGroup(int callbackId, const char* groupId)
    {
        [[EMSdkLib sharedSdkLib] leaveGroup:CreateNSString(groupId) callbackId:callbackId];
    }
    
    void _downloadAttachment(int cbId,const char* username,const char* msgId)
    {
        [[EMSdkLib sharedSdkLib] downloadAttachmentFrom:CreateNSString(username) messageId:CreateNSString(msgId) callbackId:(int)cbId];
    }

    const char* _getConversation (const char* cid, int type, bool createIfNotExists)
    {
        return MakeStringCopy([[[EMSdkLib sharedSdkLib] getConversation:CreateNSString(cid) type:type createIfNotExists:createIfNotExists] UTF8String]);
    }
    void _deleteMessagesAsExitGroup (bool del)
    {
        [[EMSdkLib sharedSdkLib] deleteMessagesAsExitGroup:del];
    }
    void _isAutoAcceptGroupInvitation(bool isAuto)
    {
        [[EMSdkLib sharedSdkLib] isAutoAcceptGroupInvitation:isAuto];
    }
    void _isSortMessageByServerTime(bool isSort)
    {
        [[EMSdkLib sharedSdkLib] isSortMessageByServerTime:isSort];
    }
    void _requireDeliveryAck(bool isReq)
    {
        [[EMSdkLib sharedSdkLib] requireDeliveryAck:isReq];
    }
}
