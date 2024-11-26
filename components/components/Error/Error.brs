sub init()
    m.global.load = false
    ' 1050X490
    m.container = m.top.findNode("container")
    m.img = m.top.findNode("img")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.description = m.top.findNode("description")

    m.top.title = m.global.texts["error_title"]
    m.top.subtitle = m.global.texts["error_subtitle"]
    m.top.description = m.global.texts["error_description"]

    m.title.font.size = 50
    m.subtitle.font.size = 30
    m.description.font.size = 25

    m.top.textColor = m.global.colors["color-text"]
    m.top.blendColor = m.global.colors["color-secondary"]
end sub

sub setTexts(event as object)
    m.title.text = m.top.title
    m.subtitle.text = m.top.subtitle
    m.description.text = m.top.description
end sub

sub setColor(event as object)
    color = event.getData()
    
    m.title.color = color
    m.subtitle.color = color
    m.description.color = color
end sub

sub setBlendColor(event as object)
    blendColor = event.getData()
    m.img.blendColor = blendColor
end sub
