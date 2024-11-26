sub init()
    m.container = m.top.findNode("container")
    m.title = m.top.findNode("title")
    m.subtitle = m.top.findNode("subtitle")
    m.description = m.top.findNode("description")
    m.link = m.top.findNode("link")
    m.rowList = m.top.findNode("rowList")

    m.title.font.size = 40
    m.subtitle.font.size = 20
    m.description.font.size = 20
    m.link.font.size = 25
    m.selected = invalid

    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({ children: setContent() }, true)
    m.rowList.content = contentNode

    m.rowList.ObserveField("rowItemSelected", "setRowItemSelected")
    m.top.ObserveField("focusedChild", "setFocusedChild")
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        m.rowList.setFocus(true)
    end if
end sub

sub setRowItemSelected(event as object)
    selected = event.getData()
    section = m.rowList.content.getChild(selected[0])
    info = section.getChild(selected[1])
    if info.component="EditTextBox"
        m.selected = info
        showdialog(section.title, info.text)
    else
        m.selected = invalid
        setYoutubeAPILocalStorage()
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Users") )
    end if
end sub

sub showdialog(title = "", text = "")
    keyboarddialog = createObject("roSGNode", "StandardKeyboardDialog")
    textEditBox = keyboarddialog.textEditBox
    textEditBox.text = text
    textEditBox.cursorPosition = Len(text)
    keyboarddialog.title = title
    keyboarddialog.buttons = ["Aceptar", "Cancelar"]
    keyboarddialog.observeFieldScoped("buttonSelected", "setButtonSelected")
    keyboarddialog.observeFieldScoped("text", "setText")

    m.global.scene.dialog = keyboarddialog
end sub

function getYoutubeAPILocalStorage()
    localStorage = CreateObject("roRegistrySection", "LocalStorage")
    youtubeAPI = {}
    if localStorage.Exists("YoutubeAPI")
        youtubeAPI = ParseJson(localStorage.Read("YoutubeAPI"))
    end if
    return youtubeAPI
end function

sub setYoutubeAPILocalStorage()
    localStorage = CreateObject("roRegistrySection", "LocalStorage")
    youtubeAPI = {}
    client_id = m.rowList.content.getChild(0).getChild(0)
    client_secret = m.rowList.content.getChild(1).getChild(0)
    
    if client_id<>invalid and client_id.text<>invalid and client_id.text<>""
        youtubeAPI["client_id"] = client_id.text
    end if
    if client_secret<>invalid and client_secret.text<>invalid and client_secret.text<>""
        youtubeAPI["client_secret"] = client_secret.text
    end if
    
    if youtubeAPI.Count()>1
        localStorage.write("YoutubeAPI", FormatJson(youtubeAPI))
        localStorage.Flush()
    else
        localStorage.Delete("YoutubeAPI")
    end if
end sub

sub setButtonSelected(event as object)
    node = event.getRoSGNode()
    button = event.getData()
    if button=0
        text = node.text
        m.selected.text = text
    end if
    node.close = true
end sub

function setContent()
    APIcredentials = ParseJson(ReadAsciifile("pkg:/components/data/APICredentials.json"))
    
    client_id = APIcredentials[0].children[0]
    client_secret = APIcredentials[1].children[0]

    youtubeAPI = getYoutubeAPILocalStorage()
    if youtubeAPI.Count()>1:
        client_id.text = youtubeAPI["client_id"]
        client_secret.text = youtubeAPI["client_secret"]
    end if
    return APIcredentials
end function