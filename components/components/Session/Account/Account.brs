sub init()
    m.defaultProfilePicture = "pkg:/images/icons/circle-user.png"
    m.defaultNickname = ""

    m.img = m.top.findNode("img")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.timer = m.top.findNode("timer")

    m.title.font.size = 50
    m.subtitle.font.size = 25

    m.titleDefault = m.global.texts["account_title"]
    
    m.title.text = m.titleDefault
    m.subtitle.text = m.global.texts["account_subtitle"]

    m.img.uri = m.defaultProfilePicture

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.timer.ObserveField("fire","setStackNavigator")
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        load()
    else if not(m.top.isInFocusChain())
    end if
end sub

sub setProfilePicture(event as Object)
    profile_picture = event.getData()

    m.img.uri = profile_picture
end sub

sub setNickname(event as Object)
    nickname = event.getData()
    
    m.title.text = m.titleDefault+", "+nickname
end sub

sub setResponse(event as Object)
    response = event.getData()

    headers = response["headers"]
    body = response["body"]

    error = response["error"]

    data = {
        account_name: m.defaultNickname,
        account_photo: m.defaultProfilePicture,
        account_byline: m.top.id
    }
    try
        if body<>invalid and body["userInfo"]<>invalid and body["userInfo"]["account_name"]<>invalid
            data = {
                account_name: body["userInfo"]["account_name"],
                account_photo: body["userInfo"]["account_photo"],
                account_byline: body["userInfo"]["account_byline"]
            }
        end if
        
        m.global.profile = data
        m.top.nickname = data["account_name"]
        m.top.profile_picture = data["account_photo"]

        if headers<>invalid and headers.DoesExist("logout")
            m.global.credentials = invalid
        end if
    catch err
        if error = invalid
            error = err
        end if
    end try
    if error<>invalid
        print(error)
        if m.global.profile = invalid
            m.global.profile = data
        end if
        m.global.credentials = invalid
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Error") )
    end if
    m.timer.control = "start"
end sub

sub load()
    m.global.load = true
    accountTask = CreateObject("roSGNode", "FetchAccount")
    accountTask.ObserveField("response", "setResponse")
    accountTask.control = "run"
end sub

sub setStackNavigator()
    m.global.load = false
    stackNavigator = CreateObject("roSGNode", "StackNavigator")
    stackNavigator.callFunc("ClearStackNavigator")
    stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Home") )
end sub