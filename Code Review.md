# Code review Silverback 3 for OS X


## General Remarks

Source code quality is good overall. Communication between parts of the app (start/stop sessions, update UI, etc.) are doing using notifications. While this is not bad as such, it makes it difficult to follow the program flow. Also with notifications it is not guaranteed that someone is listening and receives the message. I have little to no memory issues. 

I have found some issues related to creating sessions and recording that might cause the instabilities. 
The first time I started using Silverback and started recording a session the 'Stop recording' and 'Task Finished' menu items did nothing. The reason is that the recording stopped prematurely (see issue 11) and the app doesn't handle the case that the recording was stopped before the user stops it. 


##Issues found

Issues without a Time To Fix (TTF) remark will take only a few minutes to fix.

1. Possible insert of `nil` into array. `SBSessionEditViewController.m`, method `handleFinishTaskNotification:`
	
	```objc
	- (void)handleFinishTaskNotification:(NSNotification *)notification {
	    NSString *potential = notification.object;
	    
	    NSLog(@"handleFinishTaskNotification");
	    
	    if( potential && self.remainingTaskList.count ) {
	        SBKAnnotation *found = nil;
	
	        for( SBKAnnotation *check in self.remainingTaskList ) {
	            if( [check.uuid isEqualToString:potential] ) {
	                found = check;
	                break;
	            }
	        }
	
	        [self.remainingTaskList removeObject:found];
	        [self.remainingTaskList insertObject:found atIndex:0];
	    }
	    self.session.userIsExecutingTask = NO;
	     [[MultipeerConnectivityRemote shared] sendInfo:@{RemoteKeyDataEndedATask:@{@"uuid":self.self.session.uuid}} toPeer:nil callbackBlock:nil];
	
	    if( ![self startNextTask:nil] ) {
	        [self handleFinishRecordingNotification:nil];
	    }
	}
	
	```
	
	If `found` is not set then nil is inserted in `self.remainingTaskList` and the app will crash.

2. Memory leak in method `handleCursorTest:`, file `SBSessionPreviewViewController`

	Line `CGImageRef imageRef = CGBitmapContextCreateImage(context);` is not used and will leak.

3. File `Reachability.m` is compiled without ARC-support. This will cause a lot of memory leaks.

4. When a screen or camera movie is invalid (app crashes) then it is not possible to open the project anymore (crashes in `[ATAssetSampleDataProvider initWithURL:]`). `[SBKSession initWithURL:]` should check if movies are valid, if not it put the offending session back in "Ready to record" state. (**TTF: 4 hrs**)

5. In line 1166-1174 of `SBDocument.m` the `handleRequestPresentSessionsCreateNewSessionSheetNotification` is registered twice and is also called twice then a session is added. This may have undesirable consequences:

	```objc
	    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRequestPresentSessionsCreateNewSessionSheetNotification:)
                                                 name:SBRequestPresentSessionsCreateNewSessionSheetNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRequestPresentSessionsCreateNewSessionSheetNotification:)
                                                 name:SBRequestPresentSessionsCreateNewSessionSheetNotification
                                               object:nil];
	```

6. After recording a session, inserting a new session results in disabling the camera for the  thumbnail capture view of the new session. The reason is that the current session is still set to the previous one (current session is not synced with the selection of the session list on the left) (**TTF: 4 hrs**)

7. In `SBAnnotationTrackView.m`, `layoutSubtreeIfNeeded` is overwritten. This is not allowed. `layout` should be overwritten instead.

8. Delegate property in `OEXTokenFieldCell.h` should be weak. Delegate properties should be declared weak instead of assign. Weak references are safer because they become nil when the referenced object is deallocated.
9. `SBLowLevelCapture` attaches itself as a ``AVCaptureMovieFileOutput` delegate, but does not detach in `-[NSObject dealloc]`. This can cause crashes.
 
10. Some error checking is done incorrectly for methods that do return NSError. The check should be in the return value of the method. Not the NSError (e.g. `SBCuttingRoom.m line 73, 225`, `SBDocument line 636, 696`, `SBKProject.m line 252`) (**TTF: 2 hrs**)
 
11. When recording for a long time `mCameraFileOutput` and `mScreenFileOutput` in file `SBLowLevelCapture` lose their delegate (becomes nil). This causes the "Stop Recording"/"Task Finished" functions to do nothing. This causes `[self.session endCapture:]` to never execute it's block (this block show the completed session fullscreen). The reason is that the recoding was stopped (involuntary, maybe the computer went to sleep?). (**TTF: 16 hrs**)

	*Error:* 

	```
	willFinishRecordingToOutputFileAtURL <AVCaptureMovieFileOutput: 0x610000032b40> to file:///Users/diederik/Library/Containers/uk.co.clearleft.SilverbackMac/Data/Documents/Demo.silverbackproj/FB285263-8D7E-429F-B4D5-2A7D3E57BA97.session/screen.mov
	2015-09-07 17:10:18.695 Silverback[50613:4748651] didFinishRecordingToOutputFileAtURL <AVCaptureMovieFileOutput: 0x610000032b40> to file:///Users/diederik/Library/Containers/uk.co.clearleft.SilverbackMac/Data/Documents/Demo.silverbackproj/FB285263-8D7E-429F-B4D5-2A7D3E57BA97.session/screen.mov: Error Domain=AVFoundationErrorDomain Code=-11809 "Recording Stopped" UserInfo={AVErrorRecordingSuccessfullyFinishedKey=true, AVErrorDiscontinuityFlagsKey=156160, NSLocalizedRecoverySuggestion=Try recording again., NSLocalizedDescription=Recording Stopped}	
	```
	
	