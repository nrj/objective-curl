//
//  TransferRecord.h
//  objective-curl
//
//  Created by nrj on 12/15/09.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TransferRecord 

/*
 * The name of the transfer
 */
- (NSString *)name;
- (void)setName:(NSString *)aName;

/*
 * Protocol - enum kSecProtocolTypeFTP, kSecProtocolTypeSSH etc. Used to store/retreive keychain passwords.
 */
- (SecProtocolType)protocol;
- (void)setProtocol:(SecProtocolType)aProtocol;

/*
 * String representation of the protocol - "FTP", "SSH" etc. Used in status messages.
 */
- (NSString *)protocolString;

/*
 * Auth Username
 */
- (NSString *)username;
- (void)setUsername:(NSString *)aUsername;

/*
 * Host (somehost.com)
 */
- (NSString *)hostname;
- (void)setHostname:(NSString *)aHostname;

/*
 * Port number
 */
- (int)port;
- (void)setPort:(int)aPort;

/*
 * Remote directory that the files will be uploaded to 
 */
- (NSString *)directory;
- (void)setDirectory:(NSString *)aDirectory;

/*
 * Current file that is being uploaded.
 */
- (NSString *)currentFile;
- (void)setCurrentFile:(NSString *)aFile;

/*
 * Total number of files to be uploaded
 */
- (int)totalFiles;
- (void)setTotalFiles:(int)numFiles;

/*
 * Total number of files that have finished uploading
 */
- (int)totalFilesUploaded;
- (void)setTotalFilesUploaded:(int)numFiles;

/*
 * Integer status of the transfer
 */
- (int)status;
- (void)setStatus:(int)aStatus;

/*
 * Status message
 */
- (NSString *)statusMessage;
- (void)setStatusMessage:(NSString *)aStatusMessage;

/*
 * Percent complete 1-100
 */
- (int)progress;
- (void)setProgress:(int)newProgress;

/*
 * Determine if the transfer is doing actively doing something
 */
- (BOOL)isActiveTransfer;

@end