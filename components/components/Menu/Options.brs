sub init()
    m.img = m.top.findNode("img")
    m.title = m.top.findNode("title")

    m.top.layoutDirection = "horiz" 
    m.top.itemSpacings = 50
    
    setHeight()
end sub

sub setItemContent(event as Object)
    content = event.getData()

    m.img.uri = content.img
    m.title.text = content.title

    setColors(content.textColor, content.blendColor)
end sub

sub setWidth(event as Object)
    width = event.getData()    
    m.title.width = width - m.img.width - 50
end sub

sub setHeight(event = invalid as Object)
    if event <> invalid
        height = event.getData()
    else
        height = m.title.height
    end if
    
    m.title.height = height
    m.img.height = height
    m.img.width = height
end sub

sub setFocusPercent(event as Object)
    focusPercent = event.getData()
    content = m.top.itemContent
    if focusPercent>0.5
        setColors(content.focusTextColor, content.focusBlendColor)
    else
        setColors(content.textColor, content.blendColor)
    end if
end sub

sub setColors(textColor, blendColor)
    m.title.color = textColor
    m.img.blendColor = blendColor
end sub

