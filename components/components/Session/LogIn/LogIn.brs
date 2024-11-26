sub init()
    m.x_device = ""
    ' 1050X490
    m.container = m.top.findNode("container")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.description = m.top.findNode("description")
    m.link = m.top.findNode("link")
    m.codeMessage = m.top.findNode("codeMessage")
    m.code = m.top.findNode("code")
    m.qr = m.top.findNode("qr")
    m.timer = m.top.findNode("timer")

    m.top.title = m.global.texts["login_title"]
    m.top.subtitle = m.global.texts["login_subtitle"]
    m.top.description = m.global.texts["login_description"]
    m.top.codeMessage = m.global.texts["login_code_message"]
    m.top.textColor = m.global.colors["color-text"]

    m.title.font.size = 50
    m.subtitle.font.size = 25
    m.description.font.size = 25
    m.link.font.size = 30
    m.codeMessage.font.size = 25
    m.code.font.size = 30

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.timer.ObserveField("fire","load")

    setTranslation()
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        youtubeAPI = getYoutubeAPILocalStorage()
        if youtubeAPI.Count()>1
            load()
        else 
            stackNavigator = CreateObject("roSGNode", "StackNavigator")
            stackNavigator.callFunc("ClearStackNavigator")
            stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Users") )
            stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "APICredentials") )
        end if
    else if not(m.top.isInFocusChain())
    end if
end sub

sub setTexts()
    m.title.text = m.top.title
    m.subtitle.text = m.top.subtitle
    m.description.text = m.top.description
    m.codeMessage.text = m.top.codeMessage
    setTranslation()
end sub

sub setColor(event as object)
    color = event.getData()
    
    m.title.color = color
    m.subtitle.color = color
    m.description.color = color
    m.link.color = color
    m.codeMessage.color = color
    m.code.color = color
end sub

sub setTranslation()
    height = m.container.boundingRect().height
    translation = m.container.translation
    translation[1] = (720-height)/2
    m.container.translation = translation
end sub

sub setResponse(event as Object)
    response = event.getData()

    headers = response["headers"]
    body = response["body"]

    error = response["error"]
    try
        if headers<>invalid and headers["credentials"]<>invalid
            m.timer.control = "stop"
            m.global.credentials = headers["credentials"]

            stackNavigator = CreateObject("roSGNode", "StackNavigator")
            stackNavigator.callFunc("ClearStackNavigator")
            stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Account") )
        else if headers<>invalid and body<>invalid and headers["x-device"]<>invalid
            m.x_device =  headers["x-device"]
            m.code.text = body["user_code"]
            m.link.text = body["verification_url"]
            
            DeleteFile(m.qr.uri)
            
            m.qr.uri = base64(body["user_code"],body["base64"])
            m.timer.control = "start"
        else if body<>invalid and body["auth"]<>invalid and body["auth"]<>"pending"
            m.x_device = "" 
        end if
    catch err
        if error = invalid
            error = err
        end if
    end try
    if error<>invalid
        print(error)
        m.timer.control = "stop"
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Error") )
    end if
end sub

function base64(code,base)
    uri = "tmp:/"+code.toStr()+".png"

    ba = CreateObject("roByteArray")
    ba.fromBase64String(base)
    ba.writeFile(uri)
    return uri
end function

sub load()
    loginTask = CreateObject("roSGNode", "FetchLogin")
    loginTask.ObserveField("response", "setResponse")
    loginTask.setField("x_device", m.x_device)
    loginTask.control = "run"
end sub

function getYoutubeAPILocalStorage()
    localStorage = CreateObject("roRegistrySection", "LocalStorage")
    youtubeAPI = {}
    if localStorage.Exists("YoutubeAPI")
        youtubeAPI = ParseJson(localStorage.Read("YoutubeAPI"))
    end if
    return youtubeAPI
end function