sub init()
    m.load = m.top.findNode("load")

    m.load.visible = false
    m.load.poster.uri = "pkg:/images/icons/spinner.png"
    m.load.poster.width = 100
    m.load.poster.height = 100
    m.load.poster.blendColor = m.global.colors["color-secondary"]
end sub

sub setVisible(event as Object)
    visible = event.getData()
    m.load.visible = visible
    if visible
        m.load.control = "start"
    else
        m.load.control = "stop"
    end if
end sub

sub setBlendColor(event as Object)
    blendColor = event.getData()
    m.load.poster.blendColor = blendColor
end sub