sub init()
    m.img = m.top.findNode("img")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.views = m.top.findNode("views")
    m.date = m.top.findNode("date")
    m.duration = m.top.findNode("duration")

    m.title.font.size = 20
    m.subtitle.font.size = 18
    m.views.font.size = 15
    m.date.font.size = 15
end sub

sub setItemContent(event as Object)
    'contents
    content = event.getData()
    
    m.img.uri = content.thumbnails
    m.title.text = content.title
    m.subtitle.text = content.author_name
    m.views.text = content.short_view_count
    m.date.text = content.published
    m.duration.text = content.duration

    setColors(content.textColor, content.blendColor)
end sub

sub setFocusPercent(event as Object)
    focusPercent = m.top.focusPercent
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
