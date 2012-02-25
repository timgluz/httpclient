#------------------------------------------------------------------------------
#   Julia http democlient
#
#   includes http clients which are based on cURL lib.
#
#------------------------------------------------------------------------------
import("httptypes")
import("httputils")

libcurl = dlopen("libcurlclient")

function http_head(request)
    #makes HEAD request and return Response-type with status_code 

end

function http_get(request)
    #makes GET request
    url = build_uri(request)

    response =  ccall(dlsym(http_client, :get), 
        Ptr{Uint8}, (Ptr{Uint8}, ), url)
    print(cstring(response))
    return cstring(convert(Ptr{Uint8}, response))
end

function http_post(request)

end

function http_put(request)

end

function http_delete(request)


end
#-- TEST FUNCTIONS ------------------------------------------------------------

function test_get()
    url = "http://httpbin.org/ip"
    println("Making demo request to $url")
    response = http_get(url)

    println("Get response: $response")
end

function run_tests()
    test_get()

end

run_tests() #comment it out if finished
