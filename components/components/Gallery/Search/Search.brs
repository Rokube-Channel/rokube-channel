sub init()
    m.page = 0

    m.container = m.top.findNode("container")
    m.input = m.top.findNode("input")     
    m.suggestions = m.top.findNode("suggestions")
    m.keyboard = m.top.findNode("keyboard")
    m.results = m.top.findNode("results")

    m.keyboard.textEditBox.scale = [0,0]
    m.top.focusBitmapBlendColor = m.global.colors["color-text"]
    m.top.textColor = m.global.colors["color-text"]
    m.top.hintTextColor = m.global.colors["opacity-25"]
    m.top.hintText = m.global.texts["search_hint"]

    m.top.resultsTextColor = m.global.colors["color-text"]
    m.top.resultsBlendColor = m.global.colors["opacity-100"]
    m.top.resultsFocusTextColor = m.global.colors["color-text"]
    m.top.resultsFocusBlendColor = m.global.colors["opacity-100"]
    m.top.suggestionsTextColor = m.global.colors["color-text"]
    m.top.suggestionsBlendColor = m.global.colors["color-primary"]
    m.top.suggestionsFocusTextColor = m.global.colors["color-text"]
    m.top.suggestionsFocusBlendColor = m.global.colors["color-primary"]
    m.top.searchTextDefault = m.global.texts["search_message_default"]
    m.top.searchTextOK = m.global.texts["search_message_ok"]
    m.top.searchTextFail = m.global.texts["search_message_fail"]

    m.top.ObserveField("focusedChild", "setFocusedChild")
    m.keyboard.textEditBox.ObserveField("text", "setText")
    m.results.ObserveField("rowItemSelected","setRowItemSelected")
    m.results.ObserveField("rowItemFocused","setRowItemFocused")
    m.suggestions.ObserveField("itemSelected","setItemSelected")
end sub

sub setFocusedChild(event as object)
    if m.top.hasFocus()
        m.suggestions.drawFocusFeedback = false
        m.results.drawFocusFeedback = false
        m.keyboard.setFocus(true)
    else if not(m.top.isInFocusChain())
        m.suggestions.drawFocusFeedback = false
        m.results.drawFocusFeedback = false
    end if
end sub

sub setRowItemSelected(event as Object)
    selected = event.getData()
    info = m.results.content.getChild(selected[0]).getChild(selected[1])
    if info.id<>invalid
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stream = CreateObject("roSGNode", "Stream")
        stream.SetField("video_id", info.id)
        stackNavigator.callFunc("ShowScreen", stream )
    end if
end sub

sub setRowItemFocused(event as Object)
    selected = event.getData()
    info = m.results.content.getChild(selected[0]).getChild(selected[1])
    if m.results.content <> invalid 
        childrens = m.results.content.getChild(selected[0]).getChildCount()-1
        if selected[1]=childrens
            load()
        end if
    end if
end sub

sub setItemSelected(event as Object)
    selected = event.getData()
    content = m.suggestions.content.getChild(selected)
    m.keyboard.textEditBox.text = content.title
end sub

function onKeyEvent(key as String, press as Boolean)  as Boolean
    if press
        if key = "up" and m.results.isInFocusChain()
            m.results.drawFocusFeedback = false
            m.keyboard.setFocus(true)
            return true
        else if key = "right" and m.keyboard.isInFocusChain()
            m.suggestions.drawFocusFeedback = true
            m.suggestions.setFocus(true)
            return true
        else if key = "left" and m.suggestions.isInFocusChain()
            m.suggestions.drawFocusFeedback = false
            m.keyboard.setFocus(true)
            return true
        else if key = "down" and ( m.keyboard.isInFocusChain() or m.suggestions.isInFocusChain() )
            m.suggestions.drawFocusFeedback = false
            m.results.drawFocusFeedback = true
            m.results.setFocus(true)
            return true
        end if 
    end if
    return false
end function

sub setText(event as Object)
    text = event.getData()
    m.input.text = text
    if text<>""
        m.page = 0
        load()
    end if
end sub

sub setHintText(event as Object)
    hintText = event.getData()
    m.input.hintText = hintText
end sub

sub setFocusBitmapBlendColor(event as Object)
    focusBitmapBlendColor = event.getData()
    m.suggestions.focusBitmapBlendColor = focusBitmapBlendColor
    m.results.focusBitmapBlendColor = focusBitmapBlendColor
end sub

sub setHintTextColor(event as Object)
    hintTextColor = event.getData()
    m.input.hintTextColor = hintTextColor
end sub

sub setTextColor(event as object)
    textColor = m.top.textColor
    m.input.textColor = textColor
end sub

sub setResults(event as Object)
    setResultsContent()
end sub

sub setSuggestionsColor(event as Object)
    setSuggestionsContent()
end sub

sub setSuggestionsContent(event = invalid as Object)
    if event <> invalid
        content = event.getData()
    else
        content = m.top.suggestionsContent
    end if

    blendColor = m.top.suggestionsBlendColor
    textColor = m.top.suggestionsTextColor
    focusBlendColor = m.top.suggestionsFocusBlendColor
    focusTextColor = m.top.suggestionsFocusTextColor
    itemSize = m.suggestions.itemSize

    suggestionsContentNode = CreateObject("roSGNode", "ContentNode")
    suggestionList = []
    if content <> invalid and content.Count()>0
        suggestionList = content
        for i = 0 to content.Count()-1
            content[i].HDItemWidth = itemSize[0]
            content[i].HDItemHeight = itemSize[1]
            suggestionList[i].blendColor = blendColor
            suggestionList[i].textColor = textColor
            suggestionList[i].focusBlendColor = focusBlendColor
            suggestionList[i].focusTextColor = focusTextColor
        end for
    end if

    suggestionsContentNode.Update({ children: suggestionList }, true)
    m.suggestions.content = suggestionsContentNode
    m.suggestions.jumpToItem = 0
end sub

sub setResultsContent(event = invalid as Object)
    blendColor = m.top.resultsBlendColor
    textColor = m.top.resultsTextColor
    focusBlendColor = m.top.resultsFocusBlendColor
    focusTextColor = m.top.resultsFocusTextColor

    searchTextDefault = m.top.searchTextDefault
    searchTextOk = m.top.searchTextOK
    searchTextFail = m.top.searchTextFail

    if event <> invalid
        content = event.getData()

        if m.page=0
            resultsContentNode = CreateObject("roSGNode", "ContentNode")
            if content = invalid
                resultList = [ { "title": searchTextFail } ]
            else if content.Count()>0
                resultList = [ { "title": searchTextOk, "children": content } ]
                for i = 0 to content.Count()-1
                    resultList[0].children[i].blendColor = blendColor
                    resultList[0].children[i].textColor = textColor
                    resultList[0].children[i].focusBlendColor = focusBlendColor
                    resultList[0].children[i].focusTextColor = focusTextColor
                end for
            end if

            resultsContentNode.Update({ children: resultList }, true)
            m.results.content = resultsContentNode
            m.results.jumpToRowItem = [0,0]
        else
            currentContent = m.results.content.getChild(0)
            for each data in content
                item = currentContent.createChild("ContentNode")
                data.blendColor = blendColor
                data.textColor = textColor
                data.focusBlendColor = focusBlendColor
                data.focusTextColor = focusTextColor
                item.Update( data , true)
            end for
            m.global.load = true
        end if
        m.page = m.page+1
    else if m.results.content <> invalid
        content = m.results.content
        for i = 0 to content.getChild(0).getChildCount()-1
            item = content.getChild(0).getChild(i)
            item["blendColor"] = blendColor
            item["textColor"] = textColor
            item["focusBlendColor"] = focusBlendColor
            item["focusTextColor"] = focusTextColor
        end for
    else 
        content = CreateObject("roSGNode", "ContentNode")
        content.Update({ children: [ { "title": searchTextDefault } ] }, true)
        m.results.content = content
    end if
end sub

sub setResponse(event as Object)
    response = event.getData()

    headers = response["headers"]
    body = response["body"]

    error = response["error"]
    try
        if headers<>invalid and headers.DoesExist("logout")
            m.global.credentials = invalid
        end if
        if body["suggestions"]<>invalid
            m.top.suggestionsContent = body["suggestions"]
        end if
        m.top.resultsContent = body["search"]
    catch err
        if error = invalid
            error = err
        end if
    end try
    if error<>invalid
        print(error)
        stackNavigator = CreateObject("roSGNode", "StackNavigator")
        stackNavigator.callFunc("ClearStackNavigator")
        stackNavigator.callFunc("ShowScreen", CreateObject("roSGNode", "Error") )
    end if
    m.global.load = false
end sub

sub load()
    text = m.input.text
    m.global.load = true
    searchTask = CreateObject("roSGNode", "FetchSearch")
    searchTask.ObserveField("response", "setResponse")
    searchTask.setField("search", text)
    searchTask.setField("page", m.page)
    searchTask.control = "run"
end sub