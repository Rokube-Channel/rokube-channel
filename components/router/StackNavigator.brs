sub init()
    m.stackNavigator = m.global.scene.findNode("views")
end sub

sub ShowScreen(node as Object, visible = false)
    prev = CurrentScreen()

    if prev<>invalid and visible=false
        prev.visible = false
    end if

    if node.subtype() = "Login"
    
    else if node.subtype() = "Users"

    else if m.top.subtype() = "Search"
        
    else if m.top.subtype() = "Home"
        m.top.focusBitmapBlendColor = m.global.colors["color-text"]
        m.top.textColor = m.global.colors["color-text"]
        m.top.focusTextColor = m.global.colors["color-text"]
        m.top.focusBlendColor = m.global.colors["opacity-100"]
        m.top.blendColor = m.global.colors["opacity-25"]
        m.top.content = m.home
    else if  m.top.subtype()="Stream"
        overhang = m.global.scene.findNode("overhang")
        overhang.visible = false
    end if
    m.stackNavigator.AppendChild(node)
    node.setFocus(true)
end sub

sub CloseScreen()
    Pop()
    prev = CurrentScreen()
    if prev<>invalid
        prev.visible = true
        prev.setFocus(true)
    end if
end sub

sub ClearStackNavigator()
    if m.stackNavigator.getChildCount() > 0
        while m.stackNavigator.getChildCount()>0
            Pop()
        end while
        prev = CurrentScreen()
        if prev <> invalid
            prev.setFocus(true)
        end if
    end if
end sub

function CountStackNavigator()
    return m.stackNavigator.getChildCount()
end function

function CurrentScreen()
    nodeArray = m.stackNavigator
    childs = nodeArray.getChildCount()
    if childs>0
        child = nodeArray.getChild(childs-1)
        return child
    end if
    return invalid
end function

function GetScreen(child = 0)
    return m.stackNavigator.getChild(child)
end function

function Pop()
    nodeArray = m.stackNavigator
    childs = nodeArray.getChildCount()
    if childs>0
        lastChild = CurrentScreen()
        if lastChild<>invalid and lastChild.visible = true
            lastChild.visible = false
        end if
        nodeArray.removeChildIndex(childs-1)
        return lastChild
    else
        return invalid
    end if
end function
