'**********************************************************
'**  Video Player Example Application - Detail Screen 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

Function preShowDetailScreen(breadA=invalid, breadB=invalid) As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    return screen
End Function

'***************************************************************
'** The show detail screen (springboard) is where the user sees
'** the details for a show and is allowed to select a show to
'** begin playback.  This is the main event loop for that screen
'** and where we spend our time waiting until the user presses a
'** button and then we decide how best to handle the event.
'***************************************************************
Function showDetailScreen(screen As Object, showList As Object, showIndex as Integer) As Integer

    if validateParam(screen, "roSpringboardScreen", "showDetailScreen") = false return -1
    if validateParam(showList, "roArray", "showDetailScreen") = false return -1

    refreshShowDetail(screen, showList, showIndex)

    'remote key id's for left/right navigation
    remoteKeyLeft  = 4
    remoteKeyRight = 5
 
    while true
        msg = wait(0, screen.GetMessagePort())

        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRemoteKeyPressed() 
                print "Remote key pressed"
                if msg.GetIndex() = remoteKeyLeft then
                        showIndex = getPrevShow(showList, showIndex)
                        if showIndex <> -1
                            refreshShowDetail(screen, showList, showIndex)
                        end if
                else if msg.GetIndex() = remoteKeyRight
                    showIndex = getNextShow(showList, showIndex)
                        if showIndex <> -1
                           refreshShowDetail(screen, showList, showIndex)
                        end if
                endif
            else if msg.isButtonPressed() 
                print "ButtonPressed"
                if msg.GetIndex() = 1
                    sendBookmark(showList[showIndex], 0)
                    showVideoScreen(showList[showIndex])
                endif
                if msg.GetIndex() = 4
                    showVideoScreen(showList[showIndex])
                endif
                if msg.GetIndex() = 2
                    OK = ShowDialog2Buttons("Delete", "Delete this episode?", "Cancel", "OK")
                    if OK = 1
		        print "Perform delete"
		        deleteResult = sendDelete(showList[showIndex], false)
		        if deleteResult = -1
		            ShowDialog1Button("Error", "There was a problem sending the delete command.", "OK")
                        else
                            ShowDialog1Button("Delete", "The episode will be deleted as soon as possible.", "OK")
		        endif
                    endif
                endif
                if msg.GetIndex() = 3
                    OK = ShowDialog2Buttons("Delete", "Delete this episode and allow re-record?", "Cancel", "OK")
                    if OK = 1
		        print "Perform delete+rerecord"
		        deleteResult = sendDelete(showList[showIndex], true)
		        if deleteResult = -1
		            ShowDialog1Button("Error", "There was a problem sending the delete command.", "OK")
                        else
                            ShowDialog1Button("Delete", "The episode will be deleted as soon as possible.", "OK")
		        endif
                    endif
                endif
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while

    return showIndex

End Function

'**************************************************************
'** Refresh the contents of the show detail screen. This may be
'** required on initial entry to the screen or as the user moves
'** left/right on the springboard.  When the user is on the
'** springboard, we generally let them press left/right arrow keys
'** to navigate to the previous/next show in a circular manner.
'** When leaving the screen, the should be positioned on the 
'** corresponding item in the poster screen matching the current show
'**************************************************************
Function refreshShowDetail(screen As Object, showList As Object, showIndex as Integer) As Integer

    if validateParam(screen, "roSpringboardScreen", "refreshShowDetail") = false return -1
    if validateParam(showList, "roArray", "refreshShowDetail") = false return -1

    show = showList[showIndex]

    if show.contentQuality = "SD" 
        show.HDBranded = false
        show.IsHD = false
    else
        show.HDBranded = true
        show.IsHD = true
    end if
    show.StarRating = "90"
    show.ContentType = "episode" 
    show.StreamFormat = "mp4"
    show.Length = strtoi(show.Runtime)
    show.Categories = CreateObject("roArray", 5, true)
    show.Categories.Push(show.Genre)
    show.Actors = CreateObject("roArray", 5, true)
    show.Actors.Push(show.Genre)
    show.Description = show.Synopsis 

    'Uncomment this statement to dump the details for each show
    PrintAA(show)

    screen.ClearButtons()
    if getBookmark(show) = 0
        screen.AddButton(1, "Play")    
    else
        screen.AddButton(4, "Resume")
        screen.AddButton(1, "Play from beginning")
    end if
    screen.AddButton(2, "Delete")
    screen.AddButton(3, "Delete and re-record")
    screen.SetContent(show)
    screen.Show()

End Function

'********************************************************
'** Get the next item in the list and handle the wrap 
'** around case to implement a circular list for left/right 
'** navigation on the springboard screen
'********************************************************
Function getNextShow(showList As Object, showIndex As Integer) As Integer
    if validateParam(showList, "roArray", "getNextShow") = false return -1

    nextIndex = showIndex + 1
    if nextIndex >= showList.Count() or nextIndex < 0 then
       nextIndex = 0 
    end if

    show = showList[nextIndex]
    if validateParam(show, "roAssociativeArray", "getNextShow") = false return -1 

    return nextIndex
End Function


'********************************************************
'** Get the previous item in the list and handle the wrap 
'** around case to implement a circular list for left/right 
'** navigation on the springboard screen
'********************************************************
Function getPrevShow(showList As Object, showIndex As Integer) As Integer
    if validateParam(showList, "roArray", "getPrevShow") = false return -1 

    prevIndex = showIndex - 1
    if prevIndex < 0 or prevIndex >= showList.Count() then
        if showList.Count() > 0 then
            prevIndex = showList.Count() - 1 
        else
            return -1
        end if
    end if

    show = showList[prevIndex]
    if validateParam(show, "roAssociativeArray", "getPrevShow") = false return -1 

    return prevIndex
End Function
