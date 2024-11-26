sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    m.global = screen.getGlobalNode()
    m.global.addfield("scene", "node", false)
    m.global.addfield("load", "boolean", false)
    m.global.addfield("colors", "assocarray", false)
    m.global.addfield("texts", "assocarray", false)
    m.global.addfield("url_server", "string", false)
    m.global.addfield("credentials", "assocarray", false)
    m.global.addfield("profile", "assocarray", false)

    m.global.scene = screen.CreateScene("MainScene")
    m.global.colors = ParseJson(ReadAsciifile("pkg:/components/data/colors.json"))
    m.global.texts = ParseJson(ReadAsciifile("pkg:/components/data/texts.json"))
    m.global.url_server = "192.168.100.13:3000/"
    m.global.load = false
    m.global.credentials = invalid
    m.global.profile = invalid

    screen.setMessagePort(m.port)
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                return
            end if
        end if
    end while
end sub