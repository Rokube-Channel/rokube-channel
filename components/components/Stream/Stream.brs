sub init()
    m.streamTask = CreateObject("roSGNode", "FetchStream")

    m.video = m.top.findNode("video")

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.video.ObserveField("state", "setState")
end sub

sub setFocusedChild(event as object)
    overhang = m.global.scene.findNode("overhang")
    if m.top.hasFocus() and overhang.visible
        overhang.visible = false
    else if not(m.top.isInFocusChain()) and not(overhang.visible)
        overhang.visible = true
    end if
end sub

sub setState(event as Object)
    state = event.getData()
    if state = "finished"
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("CloseScreen")
    end if
end sub

sub setVideoID(event as Object)
    video_id = event.getData()
    if video_id<>""
        m.global.load = true
        m.streamTask.ObserveField("response", "setResponse")
        m.streamTask.setField("video_id", video_id)
        m.streamTask.control = "run"
    end if
end sub

function onKeyEvent(key as String, press as Boolean)  as Boolean
    if press
        if key = "ok"
            if m.video.control = "pause"
                m.video.control = "resume"
            else 
                m.video.control = "pause"
            end if 
            return true
        end if 
    end if
    return false
end function

sub setResponse(event as Object)
    response = event.getData()

    headers = response["headers"]
    body = response["body"]
    
    error = response["error"]
    try
        if headers<>invalid and headers.DoesExist("logout")
            m.global.credentials = invalid
        end if
        videocontent = createObject("RoSGNode", "ContentNode")
        videocontent.title = body["title"]
        videocontent.url = body["video_url"]

        m.video.content = videocontent
        m.video.setFocus(true)
        m.video.control = "play"
    catch err
        if error = invalid
            error = err
        end if
    end try
    if error<>invalid
        print(error)
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("CloseScreen")
    end if
    m.global.load = false
end sub