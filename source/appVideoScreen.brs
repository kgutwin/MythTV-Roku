'**********************************************************
'**  Video Player Example Application - Video Playback 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'***********************************************************
'** Create and show the video screen.  The video screen is
'** a special full screen video playback component.  It 
'** handles most of the keypresses automatically and our
'** job is primarily to make sure it has the correct data 
'** at startup. We will receive event back on progress and
'** error conditions so it's important to monitor these to
'** understand what's going on, especially in the case of errors
'***********************************************************  
Function showVideoScreen(showList As Object, showIndex as Integer)
    episode = showList[showIndex]

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
        return -1
    endif

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)

    syslog = CreateObject("roSystemLog")
    syslog.SetMessagePort(port)
    syslog.EnableType("http.connect")
    syslog.EnableType("http.error")
    syslog.EnableType("bandwidth.minute")

    startPosition = getBookmark(episode)

    screen.Show()
    screen.SetContent(episode)
    screen.SetPositionNotificationPeriod(10)
    screen.Show()

    print "seeking to position "; itostr(startPosition * 1000)
    screen.Seek(startPosition * 1000)

    'Uncomment his line to dump the contents of the episode to be played
    'PrintAA(episode)

    while true
        msg = wait(0, port)

        if type(msg) = "roVideoScreenEvent" then
            print "showVideoScreen | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            elseif msg.isPlaybackPosition()
                print "playback position: "; msg.GetIndex()
                if startPosition <> 0 and msg.GetIndex() < 10
                    print "reseeking to position "; itostr(startPosition * 1000)
                    screen.Seek(startPosition * 1000)
                else
                    sendBookmark(episode, msg.GetIndex())
                end if
                ' notify about ending time
                if (episode.duration - msg.GetIndex()) < 30
                    episode.Text = "Remaining time: " + StrI(episode.duration - msg.GetIndex()) + " sec"
                    episode.TextAttrs = {
                        Color: "#FFCCCCCC",
                        Font: "Medium",
                        HAlign: "HRight",
                        VAlign: "VBottom",
                        Direction: "LeftToRight"
                    }
                    screen.SetContent(episode)
                    screen.SetPositionNotificationPeriod(1)
                end if
            elseif msg.isRequestFailed()
                print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
                print msg.GetInfo()
            elseif msg.isStatusMessage()
                print "Video status: "; msg.GetIndex(); " " msg.GetData() 
            elseif msg.isButtonPressed()
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            else
                print "Unexpected event type: "; msg.GetType()
            end if
	elseif type(msg) = "roSystemLogEvent"
            i = msg.GetInfo()
            if i.LogType = "http.error" 
                print "http.error: "; i.HttpCode; " URL: "; i.Url
            elseif i.LogType = "http.connect"
                print "http.connect: "; i.OrigUrl; " "; i.TargetIp
            elseif i.LogType = "bandwidth.minute"
                print "bandwidth: "; i.Bandwidth
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while

    ' handle autoplay
    if episode.Autoplay
        showVideoScreen(showList, showIndex + 1)
    end if

End Function

