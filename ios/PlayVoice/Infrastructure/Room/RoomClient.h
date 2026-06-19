//
//  RoomClient.h
//  conference
//
//  Created by houxh on 2023/6/1.
//  Copyright © 2023 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class ARDCaptureController;
@class WebRTCVideoView;
@class RoomClient;

@protocol VideoRendererDelegate <NSObject>
-(WebRTCVideoView*)createVideoView:(NSString*)id_ isLocal:(BOOL)isLocal;
-(void)removeVideoView:(NSString*)id_;
@end

@protocol RoomClientDelegate <NSObject>
@optional
-(void)roomClientDidConnect:(RoomClient*)client;
-(void)roomClientDidDisconnect:(RoomClient*)client;
-(void)roomClientDidFail:(RoomClient*)client;
-(void)roomClient:(RoomClient*)client didJoinWithPeers:(NSArray*)peers;
-(void)roomClient:(RoomClient*)client peerJoined:(NSDictionary*)peerInfo;
-(void)roomClient:(RoomClient*)client peerLeft:(NSString*)peerId;
@end

@interface RoomClient : NSObject
@property(nonatomic, weak) id<VideoRendererDelegate> videoRendererDelegate;
@property(nonatomic, weak) id<RoomClientDelegate> delegate;
@property(nonatomic, assign) int64_t currentUID;
@property(nonatomic, copy) NSString *channelID;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, copy, nullable) NSString *displayName;

@property(nonatomic, assign) BOOL cameraOn;//default YES
@property(nonatomic, assign) BOOL microphoneOn;//default YES
@property(nonatomic, assign) BOOL muted;//default NO
@property(nonatomic, nullable) ARDCaptureController *captureController;

-(void)start:(NSString*)baseURL;
-(void)stop;
-(void)produceVideo;
-(void)produceAudio;
-(void)closeAudioProducer;
-(void)closeVideoProducer;
-(void)applyMuted:(BOOL)muted;
-(NSArray<NSString*>*)detectActiveSpeakerPeerIds;

@end

NS_ASSUME_NONNULL_END
