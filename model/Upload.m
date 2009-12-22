//
//  Upload.m
//  objective-curl
//
//  Created by nrj on 8/25/09.
//  Copyright 2009. All rights reserved.
//

#import "Upload.h"
#import "TransferStatus.h"


@implementation Upload

@synthesize name;

@synthesize localFiles;
@synthesize currentFile;

@synthesize username;
@synthesize hostname;
@synthesize port;
@synthesize directory;

@synthesize status;
@synthesize statusMessage;

@synthesize progress;
@synthesize maxConnections;
@synthesize totalFiles;
@synthesize totalFilesUploaded;

- (id)init
{
	if (self = [super init])
	{

	}
	return self;
}

- (void)dealloc
{
	[name release];
	[localFiles release];
	[username release];
	[hostname release];
	[directory release];
	[currentFile release];
	[statusMessage release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone 
{
    Upload *copy = [[[self class] allocWithZone: zone] init];
	
	[copy setName:[self name]];
	[copy setLocalFiles:[self localFiles]];
	[copy setCurrentFile:[self currentFile]];
	[copy setUsername:[self username]];
	[copy setHostname:[self hostname]];
	[copy setPort:[self port]];
	[copy setDirectory:[self directory]];	
	[copy setStatus:[self status]];
	[copy setStatusMessage:[self statusMessage]];
	[copy setProgress:[self progress]];
	[copy setMaxConnections:[self maxConnections]];
	[copy setTotalFiles:[self totalFiles]];
	[copy setTotalFilesUploaded:[self totalFilesUploaded]];
	
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeObject:currentFile forKey:@"currentFile"];
	[encoder encodeObject:username forKey:@"username"];
	[encoder encodeObject:hostname forKey:@"hostname"];
	[encoder encodeInt:port forKey:@"port"];
	[encoder encodeObject:directory forKey:@"directory"];
	if ([self isActiveTransfer])
	{
		[self setStatus:TRANSFER_STATUS_CANCELLED];
	}
	[encoder encodeInt:status forKey:@"status"];
	[encoder encodeObject:statusMessage forKey:@"statusMessage"];
	[encoder encodeObject:localFiles forKey:@"localFiles"];
	[encoder encodeInt:progress forKey:@"progress"];
	[encoder encodeInt:maxConnections forKey:@"maxConnections"];
	[encoder encodeInt:totalFiles forKey:@"totalFiles"];
	[encoder encodeInt:totalFilesUploaded forKey:@"totalFilesUploaded"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	name = [[decoder decodeObjectForKey:@"name"] retain];
	currentFile = [[decoder decodeObjectForKey:@"currentFile"] retain];
	username = [[decoder decodeObjectForKey:@"username"] retain];
	hostname = [[decoder decodeObjectForKey:@"hostname"] retain];
	port = [decoder decodeIntForKey:@"port"];
	directory = [[decoder decodeObjectForKey:@"directory"] retain];
	status = [decoder decodeIntForKey:@"status"];
	statusMessage = [[decoder decodeObjectForKey:@"statusMessage"] retain];
	localFiles = [[decoder decodeObjectForKey:@"localFiles"] retain];
	progress = [decoder decodeIntForKey:@"progress"];
	maxConnections = [decoder decodeIntForKey:@"maxConnections"];
	totalFiles = [decoder decodeIntForKey:@"totalFiles"];
	totalFilesUploaded = [decoder decodeIntForKey:@"totalFilesUploaded"];

	return self;
}

- (BOOL)isActiveTransfer
{
	return (status == TRANSFER_STATUS_CONNECTING || 
			status == TRANSFER_STATUS_UPLOADING || 
			status == TRANSFER_STATUS_AUTHENTICATING);
}

@end
