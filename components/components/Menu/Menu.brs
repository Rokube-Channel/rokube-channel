sub init()
    menuOptions = ParseJson(ReadAsciifile("pkg:/components/data/menuOptions.json"))

    m.container = m.top.findNode("container")
    m.options = m.top.findNode("options")

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.options.ObserveField("itemSelected","setItemSelected")

    m.top.color = m.global.colors["color-primary"]
    m.top.focusBitmapBlendColor = m.global.colors["color-secondary"]
    m.top.blendColor = m.global.colors["color-text"]
    m.top.textColor = m.global.colors["color-text"]
    m.top.focusBlendColor = m.global.colors["color-text"]
    m.top.focusTextColor = m.global.colors["color-text"]
    m.top.width="426"
    m.top.height="720"
    m.top.content = menuOptions
    setTranslation()
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        m.options.drawFocusFeedback = true
        m.options.setFocus(true)
    else if not(m.top.isInFocusChain())
        m.options.drawFocusFeedback = false
    end if
end sub

sub setItemSelected(event as object)
    selected = event.getData()
    content = m.options.content.getChild(selected)

    stackNavigator = CreateObject("roSGNode", "StackNavigator")
    stackNavigator.callFunc("ClearStackNavigator")
    stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", content.link) )
end sub

sub setWidth(event as Object)
    width = event.getData()
    translation = m.options.translation
    itemSize = m.options.itemSize

    translation[0] = width*0.10
    itemSize[0] = width-100

    m.container.width = width
    m.options.itemSize = itemSize
    m.options.translation = translation

    setContent()
end sub

sub setHeight(event as Object)
    height = event.getData()
    m.container.height = height
end sub

sub setColor(event as Object)
    color = event.getData()
    m.container.color = color
end sub

sub setFocusBitmapBlendColor(event as Object)
    focusBitmapBlendColor = event.getData()
    m.options.focusBitmapBlendColor = focusBitmapBlendColor
end sub

sub setOptionColor(event = invalid as Object)
    setContent()
end sub

sub setContent(event = invalid as Object)
    if event <> invalid
        content = event.getData()
    else
        content = m.top.content
    end if
    width = m.top.width
    height = m.top.height
    translation = m.options.translation
    blendColor = m.top.blendColor
    textColor = m.top.textColor
    focusBlendColor = m.top.focusBlendColor
    focusTextColor = m.top.focusTextColor
    size = 0

    for i=0 to content.Count()-1 
        content[i].HDItemWidth = width-(width*0.10*2)
        content[i].HDItemHeight = height
        content[i].blendColor = blendColor
        content[i].textColor = textColor
        if content[i].focusBlendColor=invalid
            content[i].focusBlendColor = focusBlendColor
        end if
        content[i].focusTextColor = focusTextColor
    end for

    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({ children: content }, true)
    m.options.content = contentNode

    size = m.options.boundingRect().height
    if height>size
        translation[1] = (height-size)/2
        m.options.translation = translation
    else
        translation[1] = height*0.10
    end if
end sub

sub setTranslation()

    heightContainer = m.container.boundingRect().height
    heightOptions = m.options.boundingRect().height
    
    translation = m.options.translation
    translation[1] = (heightContainer-heightOptions)/2
    m.options.translation = translation
end sub