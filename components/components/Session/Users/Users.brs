sub init()
    ' 1050X490
    defaultUsers = ParseJson(ReadAsciifile("pkg:/components/data/users.json"))

    m.container = m.top.findNode("container")
    m.users = m.top.findNode("users")
    m.logout = m.top.findNode("logout")

    m.top.focusBitmapBlendColor = m.global.colors["color-text"]
    m.top.textColor = m.global.colors["color-text"]
    m.top.focusTextColor = m.global.colors["color-text"]
    m.top.focusBlendColor = m.global.colors["opacity-100"]
    m.top.blendColor = m.global.colors["opacity-25"]
    
    m.top.content = getContent(defaultUsers)

    m.top.ObserveField("focusedChild", "setFocusedChild")

    m.users.ObserveField("itemSelected","setItemSelected")
    m.logout.ObserveField("itemSelected","setItemSelected")

    m.users.ObserveField("itemFocused","setItemFocused")
    m.logout.ObserveField("itemFocused","setItemFocused")

    setTranslation()
end sub

sub setFocusedChild(event as object)
    focus = event.getData()
    if m.top.hasFocus()
        m.users.drawFocusFeedback = true
        m.users.setFocus(true)
    else if not(m.top.isInFocusChain())
        m.users.drawFocusFeedback = false
    end if
end sub

function onKeyEvent(key as String, press as Boolean)  as Boolean
    if press
        if key = "up"
            m.logout.drawFocusFeedback = false
            m.users.drawFocusFeedback = true
            m.users.setFocus(true)
            return true
        else if key = "down"
            m.users.drawFocusFeedback = false
            m.logout.drawFocusFeedback = true
            m.logout.setFocus(true)
            return true
        end if 
    end if
    return false
end function

sub setItemSelected(event as Object)
    selected = event.getData()
    grid = event.getRoSGNode()
    node = event.getNode()

    content = grid.content.getChild(selected)
    stackNavigator = CreateObject("roSGNode", "StackNavigator")
    if node="users"
        if content.DoesExist("link")
            stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", content["link"]) )
        else
            m.global.credentials = content["credentials"]
            
            account = CreateObject("roSGNode", "Account")
            account.setField("profile_picture", content["account_photo"])
            account.setField("nickname", content["account_name"])
            account.setField("id", content["account_byline"])
            stackNavigator.callFunc("ShowScreen", account )
        end if
    else
        if not(content.DoesExist("link"))
            m.global.credentials = content["credentials"]
            
            logout = CreateObject("roSGNode", "LogOut")
            logout.setField("profile_picture", content["account_photo"])
            logout.setField("nickname", content["account_name"])
            logout.setField("id", content["account_byline"])
            stackNavigator.callFunc("ShowScreen", logout )
        end if
    end if
end sub

sub setItemFocused(event as Object)
    focused = event.getData()
    grid = event.getRoSGNode()
    node = event.getNode()
    
    content = grid.content.getChild(focused)
    if node = "users"
        m.logout.animateToItem = focused
    else if content.DoesExist("link")
        m.logout.drawFocusFeedback = false
        m.users.drawFocusFeedback = true
        m.users.setFocus(true)
    else
        m.users.animateToItem = focused
    end if
end sub

sub setFocusBitmapBlendColor(event as Object)
    focusBitmapBlendColor = event.getData()
    m.users.focusBitmapBlendColor = focusBitmapBlendColor
end sub

sub setUsersColor(event = invalid as Object)
    setContent()
end sub

sub setContent(event = invalid as Object)
    if event <> invalid
        content = event.getData()
    else
        content = m.top.content
    end if

    blendColor = m.top.blendColor
    textColor = m.top.textColor
    focusBlendColor = m.top.focusBlendColor
    focusTextColor = m.top.focusTextColor

    subcontent = []
    for i=0 to content.Count()-1 
        content[i].blendColor = blendColor
        content[i].textColor = textColor
        content[i].focusBlendColor = focusBlendColor
        content[i].focusTextColor = focusTextColor

        clone = {}
        for each key in content[i].Keys()
            if key="account_photo" and content[i].DoesExist("link")
                clone["hdgridposterurl"] = ""
            else if key="account_photo" and not(content[i].DoesExist("link"))
                clone["hdgridposterurl"] = "pkg:/images/icons/trash.png"
            else 
                clone[key] = content[i][key]
            end if
        end for
        subcontent.push(clone)
    end for

    contentNode = CreateObject("roSGNode", "ContentNode")
    subcontentNode = CreateObject("roSGNode", "ContentNode")

    contentNode.Update({ children: content }, true)
    subcontentNode.Update({ children: subcontent }, true)

    m.users.content = contentNode
    m.logout.content = subcontentNode
    setTranslation()
end sub

sub setTranslation()
    height = m.container.boundingRect().height
    translation = m.container.translation
    translation[1] = (720-height)/2
    m.container.translation = translation
end sub

function getContent(defaultUsers)
    localStorage = CreateObject("roRegistrySection", "LocalStorage")
    users = []    
    if localStorage.Exists("Users")
        users = ParseJson(localStorage.Read("Users"))
    end if

    for each user in defaultUsers
        users.Push(user)
    end for

    return users
end function