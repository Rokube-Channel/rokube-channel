sub init()
    m.top.functionName = "request"
end sub

sub request()
    rsp = {  }
    try
        page = m.top.page.ToStr()
        search = ""
        if m.top.search<>invalid
            search = m.top.search.Replace(" ", "%20")
        end if
        xfer = CreateObject("roURLTransfer")
        xfer.RetainBodyOnError(true)
        xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        xfer.SetRequest("GET")
        if m.global.credentials<>invalid
            youtubeAPI = getYoutubeAPILocalStorage()
            xfer.AddHeader("Authorization", "Bearer "+FormatJson(m.global.credentials))
            if youtubeAPI<>invalid
                xfer.AddHeader("clientid", youtubeAPI["client_id"])
                xfer.AddHeader("clientsecret", youtubeAPI["client_secret"])
            end if
        end if
        xfer.SetURL(m.global.url_server+"search?s="+search+"&page="+page)
        
        port = CreateObject("roMessagePort")
        xfer.SetMessagePort(port)
        xfer.AsyncGetToString()
        response = Wait(0, port)

        headers = response.GetResponseHeaders()
        body = response.GetString()

        rsp = { 
            headers: headers, 
            body: parseJSON(body)
        }
    catch error
        rsp = { "error": error }
    end try
    m.top.response = rsp
end sub

function getYoutubeAPILocalStorage()
    localStorage = CreateObject("roRegistrySection", "LocalStorage")
    youtubeAPI = invalid
    if localStorage.Exists("YoutubeAPI")
        youtubeAPI = ParseJson(localStorage.Read("YoutubeAPI"))
    end if
    return youtubeAPI
end function