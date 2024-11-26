sub init()
end sub

sub setItemContent(event as Object)
    'contents
    content = event.getData()
    child = invalid

    if not(content.DoesExist("init")) 
        content.addField("init", "boolean", false)
        content.init = true
        if content.component = "Button"
            m.top.color = "#D72323"
            m.top.width = 500
            m.top.height = 50
            child = CreateObject("roSGNode", "Label")
        else 
            m.top.color = "#FFFFFF00"
            child = CreateObject("roSGNode", "TextEditBox")
        end if
        m.top.appendChild(child)
        m.top.itemContent = content
    end if

    child = m.top.getChild(0)
    if content.component = "Button"
        child.vertAlign = "center"
        child.horizAlign = "center"
    end if

    child.text = content.text
    child.width = 500
    child.height = 50
end sub
