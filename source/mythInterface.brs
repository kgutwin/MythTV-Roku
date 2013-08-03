
Function sendDelete(episode As Object, forgetOld As Boolean)

    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
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