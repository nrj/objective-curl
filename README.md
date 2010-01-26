The objective-curl framework is an easy-to-use interface to the [libcurl C API](http://curl.haxx.se/libcurl/c/) for Cocoa developers. My first and foremost efforts are primarily focusing on FTP support. There are a couple frameworks out there for libcurl that subclass NSURLHandle, which has been deprecated since 10.4. This framework is designed for newer Cocoa applicaations using OS X 10.5 and higher - it uses  [NSObject](http://developer.apple.com/mac/library/documentation/cocoa/reference/Foundation/Classes/NSObject_Class/Reference/Reference.html), [NSOperation](http://developer.apple.com/mac/library/DOCUMENTATION/Cocoa/Reference/NSOperation_class/Reference/Reference.html) and [NSOperationQueue](http://developer.apple.com/mac/library/DOCUMENTATION/Cocoa/Reference/NSOperationQueue_class/Reference/Reference.html#//apple_ref/occ/cl/NSOperationQueue) for threading and your traditional cocoa delegate patterns.

## Simple FTP/SFTP Example

    CurlFTP *ftp = [[CurlFTP alloc] init];

    [ftp setVerbose:YES]
    [ftp setShowProgress:YES];
    [ftp setAuthUsername:@"me"];
    [ftp setAuthPassword:@"mypassword"];
    
    // See the CurlDelegate protocol
    [ftp setDelegate:self];
    
    // feel free to mix and match files and directories
    NSArray *filesToUpload = [[NSArray alloc] initWithObjects:@"/path/to/musicfile.mp3", 
                                                              @"/path/to/directory", 
                                                              @"/path/to/moviefile.avi", NULL];
    // kick off the upload on a background thread
    [ftp uploadFilesAndDirectories:filesToUpload toHost:@"localhost" directory:@"~/tmp"];
    
    // SFTP is simply a subclass of FTP and could be used in the exact same way

## License
Copyright (c) 2009 Nick Jensen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.