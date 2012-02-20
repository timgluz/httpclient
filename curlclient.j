#------------------------------------------------------------------------------
#   Julia http democlient
#
#------------------------------------------------------------------------------

http_client = dlopen("curlclient")


function http_get(url)
    response =  ccall(http_client, Ptr{Uint8}, (Ptr{Uint8}, ), url)
    print(cstring(response))
    return cstring(convert(Ptr{Uint8}, response))
end

function test_get()
    url = "http://httpbin.org/ip"
    println("Making demo request to $url")
    response = http_get(url)

    println("Get response: $response")
end

test_get()
