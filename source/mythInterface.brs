
Function sendBookmark(episode As Object, position As Integer)

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to sendBookmark"
        return -1
    endif

    h = NewHttp("http://mythbackend.gutwin.org/cgi-bin/bookmark.py")
    h.AddParam("pos", position)
    h.AddParam("chanid", episode.Chanid)
    h.AddParam("starttime", episode.StartTime)

    r = h.GetToStringWithTimeout(5)
    if r = "" then
        return -1
    end if

    return 0

End Function

Function getBookmark(episode As Object)

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to getBookmark"
        return -1
    endif

    h = NewHttp("http://mythbackend.gutwin.org/cgi-bin/bookmark.py")
    h.AddParam("chanid", episode.Chanid)
    h.AddParam("starttime", episode.StartTime)

    r = h.GetToStringWithTimeout(5)
    if r = "" then
        return -1
    end if

    return strtoi(r)

End Function

Function sendDelete(episode As Object, forgetOld As Boolean)

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to sendDelete"
        return -1
    endif

    h = NewHttp("http://mythbackend.gutwin.org/mythweb/tv/recorded")
    h.AddParam("delete", "yes")
    h.AddParam("chanid", episode.Chanid)
    h.AddParam("starttime", episode.StartTime)
    if forgetOld = true then
        h.AddParam("forget_old", "yes")
    end if

    r = h.GetToStringWithTimeout(30)
    if r = "" then
        return -1
    end if

    return 0

End Function