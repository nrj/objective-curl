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
@synthesize protocol;
@synthesize hostname;
@synthesize directory;
@synthesize username;
@synthesize port;

@synthesize progress;
@synthesize totalFiles;
@synthesize totalFilesUploaded;
@synthesize currentFile;

@synthesize status;
@synthesize statusMessage;


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
	[copy setProtocol:[self protocol]];
	[copy setCurrentFile:[self currentFile]];
	[copy setUsername:[self username]];
	[copy setHostname:[self hostname]];
	[copy setPort:[self port]];
	[copy setDirectory:[self directory]];	
	[copy setStatus:[self status]];
	[copy setStatusMessage:[self statusMessage]];
	[copy setProgress:[self progress]];
	[copy setTotalFiles:[self totalFiles]];
	[copy setTotalFilesUploaded:[self totalFilesUploaded]];
	
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:name forKey:@"name"];
	[encoder encodeInt32:protocol forKey:@"protocol"];
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
	[encoder encodeInt:progress forKey:@"progress"];
	[encoder encodeInt:totalFiles forKey:@"totalFiles"];
	[encoder encodeInt:totalFilesUploaded forKey:@"totalFilesUploaded"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	name = [[decoder decodeObjectForKey:@"name"] retain];
	protocol = (SecProtocolType)[decoder decodeInt32ForKey:@"protocol"];
	currentFile = [[decoder decodeObjectForKey:@"currentFile"] retain];
	username = [[decoder decodeObjectForKey:@"username"] retain];
	hostname = [[decoder decodeObjectForKey:@"hostname"] retain];
	port = [decoder decodeIntForKey:@"port"];
	directory = [[decoder decodeObjectForKey:@"directory"] retain];
	status = [decoder decodeIntForKey:@"status"];
	statusMessage = [[decoder decodeObjectForKey:@"statusMessage"] retain];
	progress = [decoder decodeIntForKey:@"progress"];
	totalFiles = [decoder decodeIntForKey:@"totalFiles"];
	totalFilesUploaded = [decoder decodeIntForKey:@"totalFilesUploaded"];

	return self;
}

- (NSString *)protocolString
{
	return [[[NSFileTypeForHFSTypeCode(protocol) stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] 
				stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
}

- (BOOL)isActiveTransfer
{
	return (status == TRANSFER_STATUS_CONNECTING || 
			status == TRANSFER_STATUS_UPLOADING || 
			status == TRANSFER_STATUS_AUTHENTICATING);
}

@end
