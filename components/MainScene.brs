sub init()
    ' hd 1280 X 720
    colors = ParseJson(ReadAsciifile("pkg:/components/data/colors.json"))
    texts = ParseJson(ReadAsciifile("pkg:/components/data/texts.json"))

    m.defaultUsers = ParseJson(ReadAsciifile("pkg:/components/data/users.json"))
    m.menuOptions = ParseJson(ReadAsciifile("pkg:/components/data/menuOptions.json"))

    m.top.backgroundUri = ""
    m.top.backgroundColor = m.global.colors["color-bg"]

    m.menuAnimation = m.top.FindNode("menuAnimation")
    m.overhang = m.top.findNode("overhang")
    m.menu = m.top.findNode("menu")
    m.views = m.top.findNode("views")
    m.load = m.top.findNode("load")

    m.overhang.optionsText = m.global.texts["options"]
    m.overhang.title = m.global.texts["name"]
    m.overhang.logoUri = "pkg:/images/favicon.png"

    m.menu.ObserveField("focusedChild", "setViewsFocusedChild")
    m.global.ObserveField("load", "setLoad")
    m.global.ObserveField("credentials", "setCredentials")
    m.global.ObserveField("profile", "setProfile")

    stackNavigator = CreateObject("roSGNode", "StackNavigator")
    stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Users") )
end sub

sub setViewsFocusedChild(event as Object)
    if m.menu.isInFocusChain() and m.menu.scale[0]<1
        child = m.menuAnimation.getChild(0)
        child.reverse = "false"
        m.menuAnimation.control = "start"
    else if not(m.menu.isInFocusChain()) and m.menu.scale[0]>0
        child = m.menuAnimation.getChild(0)
        child.reverse = "true"
        m.menuAnimation.control = "start"
    end if
end sub

function onKeyEvent(key as String, press as Boolean)  as Boolean
    if press
        if m.global.load=false
            if key = "options" and m.menu.isInFocusChain()
                current = m.views.getChild(m.views.getChildCount()-1)
                current.setFocus(true)
                return true
            else if key = "options"
                m.menu.setFocus(true)
                return true
            else if key = "back"
                m.global.load = false
                stackNavigator = CreateObject("roSGNode", "StackNavigator")
                current = stackNavigator.callFunc("CurrentScreen")
                stackNavigator.callFunc("CloseScreen")
                childs = stackNavigator.callFunc("CountStackNavigator")
                if childs=0 and not(current.isSubtype("Home"))
                    stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Home") )
                    return true
                else if childs>0
                    return true
                end if
            end if 
        else
            return true
        end if
    end if
    return false
end function

sub setLoad(event as Object)
    load = event.getData()
    m.load.load = load
end sub

sub setProfile(event as object)
    profile = event.getData()
    profiles = m.menu.content
    if profile<>invalid and profile["account_name"]<>"" and profiles.Count()>0
        profiles[0]["title"] = profile["account_name"]
        profiles[0]["img"] = profile["account_photo"]
        setUsersLocalStorage(profile["account_byline"],profile)
    else
        profiles = m.menuOptions
    end if
    m.menu.content = profiles
end sub

sub setCredentials(event as object)
    if m.global.credentials=invalid and m.global.profile<>invalid and m.global.profile["account_byline"]<>""
        removeUsersLocalStorage(m.global.profile["account_byline"])

        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        
        LogOut = CreateObject("roSGNode", "LogOut")
        LogOut.setField("nickname", m.defaultUsers[1]["account_name"])
        LogOut.setField("profile_picture", m.defaultUsers[1]["account_photo"])

        stackNavigator.callFunc("ShowScreen", LogOut )
    end if
end sub

sub setUsersLocalStorage(id, data)
    if data<>invalid
        localStorage = CreateObject("roRegistrySection", "LocalStorage")
        userExist = false
        users = []
        user = {}
        if localStorage.Exists("Users")
            users = ParseJson(localStorage.Read("Users"))
        end if

        for i = 0 to users.Count() - 1
            if users[i].DoesExist("account_byline") and users[i]["account_byline"] = id
                user = users[i]
                userExist = true
                exit for 
            end if 
        end for

        user["account_name"] = data["account_name"]
        user["account_photo"] = data["account_photo"]
        user["account_byline"] = data["account_byline"]

        if userExist=false and m.global.credentials<>invalid
            user["credentials"] = m.global.credentials
            users.Push(user)
        end if
        localStorage.write("Users", FormatJson(users))
        localStorage.Flush()
    end if
end sub

sub removeUsersLocalStorage(id)
    if id<>invalid
        localStorage = CreateObject("roRegistrySection", "LocalStorage")
        users = []
        if localStorage.Exists("Users")
            users = ParseJson(localStorage.Read("Users"))
        end if

        for i = 0 to users.Count() - 1
            if users[i].DoesExist("account_byline") and users[i]["account_byline"] = id
                users.Delete(i)
                exit for 
            end if 
        end for

        localStorage.write("Users", FormatJson(users))
        localStorage.Flush()
    end if
end sub