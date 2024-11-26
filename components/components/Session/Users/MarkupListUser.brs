sub init()
    m.img = m.top.findNode("img")
    m.title = m.top.findNode("title")

    m.top.itemSpacings = 20
    m.title.font.size = 25   
end sub

sub setItemContent(event as Object)
    content = event.getData()

    m.img.uri = content.account_photo
    m.title.text = content.account_name

    setColors(content.textColor, content.blendColor)
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

