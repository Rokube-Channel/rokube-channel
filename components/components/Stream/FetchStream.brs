sub init()
    m.top.functionName = "request"
end sub

sub request()
    rsp = {  }
    try
        video_id = ""
        if m.top.video_id<>invalid
            video_id = m.top.video_id
        end if
        xfer = CreateObject("roURLTransfer")
        xfer.RetainBodyOnError(true)
        xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        xfer.SetRequest("GET")
        if m.global.credentials<>invalid
            xfer.AddHeader("Authorization", "Bearer "+FormatJson(m.global.credentials))
        end if
        xfer.SetURL(m.global.url_server+"video?id="+video_id)
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