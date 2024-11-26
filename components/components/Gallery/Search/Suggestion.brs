sub init()
    m.title = m.top.findNode("title")
    m.title.font.size = 20
end sub

sub setItemContent(event as Object)
    content = event.getData()

    m.title.text = content.title

    setColors(content.textColor, content.blendColor)
end sub

sub setWidth(event as Object)
    width = event.getData()    
    m.title.width = width
    m.top.width = width
end sub

sub setHeight(event = invalid as Object)
    height = event.getData()
    m.title.height = height
    m.title.vertAlign = "center"
    m.top.height = height
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
    m.top.color = blendColor
end sub

