sub init()
    m.page = 0

    m.container = m.top.findNode("container")
    m.results = m.top.findNode("results")

    m.top.focusBitmapBlendColor = m.global.colors["color-text"]
    m.top.textColor = m.global.colors["color-text"]
    m.top.focusTextColor = m.global.colors["color-text"]
    m.top.focusBlendColor = m.global.colors["opacity-100"]
    m.top.blendColor = m.global.colors["opacity-100"]

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.results.ObserveField("itemSelected","setItemSelected")
    m.results.ObserveField("itemFocused","setItemFocused")
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        m.results.drawFocusFeedback = true
        m.results.setFocus(true)
        if m.top.content.Count()<1
            load()
        end if
    else if not(m.top.isInFocusChain())
        m.results.drawFocusFeedback = false
    end if
end sub

sub setItemSelected(event as Object)
    selected = event.getData()
    info = m.results.content.getChild(selected)
    if info.id<>invalid
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stream = CreateObject("roSGNode", "Stream")
        stream.SetField("video_id", info.id)
        stackNavigator.callFunc("ShowScreen", stream )
    end if
end sub

sub setItemFocused(event as object)
    selected = event.getData()
    if m.results.content <> invalid and m.results.content.getChildCount()>0
        childrens = m.results.content.getChildCount()-4
        if selected>childrens
            load()
        end if
    end if
end sub

sub setFocusBitmapBlendColor(event as Object)
    focusBitmapBlendColor = event.getData()
    m.results.focusBitmapBlendColor = focusBitmapBlendColor
end sub

sub setContentAux(event as Object)
    setContent()
end sub

sub setContent(event = invalid as Object)
    blendColor = m.top.blendColor
    textColor = m.top.textColor
    focusBlendColor = m.top.focusBlendColor
    focusTextColor = m.top.focusTextColor

    if event <> invalid
        content = event.getData()
        currentContent = m.results.content
        for each data in content
            item = currentContent.createChild("ContentNode")
            data.blendColor = blendColor
            data.textColor = textColor
            data.focusBlendColor = focusBlendColor
            data.focusTextColor = focusTextColor
            item.Update( data , true)
        end for
        m.page = m.page+1
    else if m.results.content <> invalid
        content = m.results.content
        for i = 0 to content.getChildCount()-1
            item = content.getChild(i)
            item["blendColor"] = blendColor
            item["textColor"] = textColor
            item["focusBlendColor"] = focusBlendColor
            item["focusTextColor"] = focusTextColor
        end for
    else
        content = CreateObject("roSGNode", "ContentNode")
        content.Update({}, true)
        m.results.content = content
    end if
end sub

sub setResponse(event as Object)
    response = event.getData()

    headers = response["headers"]
    body = response["body"]

    error = response["error"]
    try
        if headers<>invalid and headers.DoesExist("logout")
            m.global.credentials = invalid
        end if
        m.top.content = body["history"]
    catch err
        if error = invalid
            error = err
        end if
    end try
    if error<>invalid
        print(error)
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Error") )
    end if
    m.global.load = false
end sub

sub load()
    if not(m.global.load)
        m.global.load = true
        historyTask = CreateObject("roSGNode", "FetchHistory")
        historyTask.ObserveField("response", "setResponse")
        historyTask.setField("page", m.page)
        historyTask.control = "run"
    end if
end sub