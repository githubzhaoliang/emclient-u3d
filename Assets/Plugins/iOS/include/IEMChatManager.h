/*!
 *  \~chinese
 *  @header IEMChatManager.h
 *  @abstract 此协议定义了聊天相关操作
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMChatManager.h
 *  @abstract This protocol defines the operations of chat
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"
#import "EMChatManagerDelegate.h"
#import "EMConversation.h"

#import "EMMessage.h"
#import "EMTextMessageBody.h"
#import "EMLocationMessageBody.h"
#import "EMCmdMessageBody.h"
#import "EMFileMessageBody.h"
#import "EMImageMessageBody.h"
#import "EMVoiceMessageBody.h"
#import "EMVideoMessageBody.h"

@class EMError;

/*!
 *  \~chinese
 *  聊天相关操作
 *
 *  \~english
 *  Operations of chat
 */
@protocol IEMChatManager <NSObject>

@required

#pragma mark - Delegate

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Delegate
 *  @param aQueue     The queue of call delegate method
 */
- (void)addDelegate:(id<EMChatManagerDelegate>)aDelegate
      delegateQueue:(dispatch_queue_t)aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 *  @param aDelegate  Delegate
 */
- (void)removeDelegate:(id<EMChatManagerDelegate>)aDelegate;

#pragma mark - Conversation

/*!
 *  \~chinese
 *  获取所有会话，如果内存中不存在会从DB中加载
 *
 *  @result 会话列表<EMConversation>
 *
 *  \~english
 *  Get all conversations, by loading conversations from DB if not exist in memory
 *
 *  @result Conversation list<EMConversation>
 */
- (NSArray *)getAllConversations;

/*!
 *  \~chinese
 *  获取一个会话
 *
 *  @param aConversationId  会话ID
 *  @param aType            会话类型
 *  @param aIfCreate        如果不存在是否创建
 *
 *  @result 会话对象
 *
 *  \~english
 *  Get a conversation
 *
 *  @param aConversationId  Conversation id
 *  @param aType            Conversation type
 *  @param aIfCreate        Whether create conversation if not exist
 *
 *  @result Conversation
 */
- (EMConversation *)getConversation:(NSString *)aConversationId
                               type:(EMConversationType)aType
                   createIfNotExist:(BOOL)aIfCreate;

/*!
 *  \~chinese
 *  删除会话
 *
 *  @param aConversationId      会话ID
 *  @param isDeleteMessages     是否删除会话中的消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Delete a conversation
 *
 *  @param aConversationId      Conversation id
 *  @param isDeleteMessages     Whether delete messages
 *  @param aCompletionBlock     The callback block of completion
 *
 */
- (void)deleteConversation:(NSString *)aConversationId
          isDeleteMessages:(BOOL)aIsDeleteMessages
                completion:(void (^)(NSString *aConversationId, EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  删除一组会话
 *
 *  @param aConversations       会话列表<EMConversation>
 *  @param aIsDeleteMessages    是否删除会话中的消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Delete multiple conversations
 *
 *  @param aConversations       Conversation list<EMConversation>
 *  @param aIsDeleteMessages    Whether delete messages
 *  @param aCompletionBlock     The callback block of completion
 *
 */
- (void)deleteConversations:(NSArray *)aConversations
           isDeleteMessages:(BOOL)aIsDeleteMessages
                 completion:(void (^)(EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  导入一组会话到DB
 *
 *  @param aConversations   会话列表<EMConversation>
 *  @param aCompletionBlock 完成的回调
 *
 *
 *  \~english
 *  Import multiple conversations to DB
 *
 *  @param aConversations   Conversation list<EMConversation>
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)importConversations:(NSArray *)aConversations
                 completion:(void (^)(EMError *aError))aCompletionBlock;

#pragma mark - Message

/*!
 *  \~chinese
 *  获取消息附件路径, 存在这个路径的文件，删除会话时会被删除
 *
 *  @param aConversationId  会话ID
 *
 *  @result 附件路径
 *
 *  \~english
 *  Get message attachment local path for the conversation. Delete the conversation will also delete the files under the file path.
 *
 *  @param aConversationId  Conversation id
 *
 *  @result Attachment path
 */
- (NSString *)getMessageAttachmentPath:(NSString *)aConversationId;

/*!
 *  \~chinese
 *  导入一组消息到DB
 *
 *  @param aMessages  消息列表<EMMessage>
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Import multiple messages
 *
 *  @param aMessages  Message list<EMMessage>
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)importMessages:(NSArray *)aMessages
            completion:(void (^)(EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  更新消息到DB
 *
 *  @param aMessage  消息
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Update message
 *
 *  @param aMessage  Message
 *  @param aSuccessBlock    The callback block of completion
 *
 */
- (void)updateMessage:(EMMessage *)aMessage
           completion:(void (^)(EMMessage *aMessage, EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  发送消息已读回执
 *
 *  异步方法
 *
 *  @param aMessage  消息
 *  @param aCompletionBlock    完成的回调
 *
 *  \~english
 *  Send read acknowledgement for message
 *
 *
 *  @param aMessage  Message instance
 *  @param aCompletionBlock    The callback block of completion
 *
 */
- (void)sendMessageReadAck:(EMMessage *)aMessage
                     completion:(void (^)(EMMessage *aMessage, EMError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  发送消息
 *
 *  @param aMessage         消息
 *  @param aProgressBlock   附件上传进度回调block
 *  @param aCompletion      发送完成回调block
 *
 *  \~english
 *  Send a message
 *
 *
 *  @param aMessage            Message instance
 *  @param aProgressBlock      The block of attachment upload progress
 *  @param aCompletion         The block of send complete
 */
- (void)sendMessage:(EMMessage *)aMessage
           progress:(void (^)(int progress))aProgressBlock
         completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  重发送消息
 *
 *  @param aMessage         消息
 *  @param aProgressBlock   附件上传进度回调block
 *  @param aCompletion      发送完成回调block
 *
 *  \~english
 *  Resend Message
 *
 *  @param aMessage         Message instance
 *  @param aProgressBlock   The callback block of attachment upload progress
 *  @param aCompletion      The callback block of send complete
 */
- (void)resendMessage:(EMMessage *)aMessage
                  progress:(void (^)(int progress))aProgressBlock
                completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  下载缩略图（图片消息的缩略图或视频消息的第一帧图片），SDK会自动下载缩略图，所以除非自动下载失败，用户不需要自己下载缩略图
 *
 *  @param aMessage            消息
 *  @param aProgressBlock      附件下载进度回调block
 *  @param aCompletion         下载完成回调block
 *
 *  \~english
 *  Download message thumbnail (thumbnail of image message or first frame of video image), SDK downloads thumbails automatically, no need to download thumbail manually unless automatic download failed.
 *
 *  @param aMessage            Message instance
 *  @param aProgressBlock      The callback block of attachment download progress
 *  @param aCompletion         The callback block of download complete
 */
- (void)downloadMessageThumbnail:(EMMessage *)aMessage
                        progress:(void (^)(int progress))aProgressBlock
                      completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  下载消息附件（语音，视频，图片原图，文件），SDK会自动下载语音消息，所以除非自动下载语音失败，用户不需要自动下载语音附件
 *
 *  异步方法
 *
 *  @param aMessage            消息
 *  @param aProgressBlock      附件下载进度回调block
 *  @param aCompletion         下载完成回调block
 *
 *  \~english
 *  Download message attachment(voice, video, image or file), SDK downloads attachment automatically, no need to download attachment manually unless automatic download failed
 *
 *
 *  @param aMessage            Message instance
 *  @param aProgressBlock      The callback block of attachment download progress
 *  @param aCompletion         The callback block of download complete
 */
- (void)downloadMessageAttachment:(EMMessage *)aMessage
                         progress:(void (^)(int progress))aProgressBlock
                       completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

@end
