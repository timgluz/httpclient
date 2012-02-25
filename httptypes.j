#------------------------------------------------------------------------------
#httptypes.j
#
#   Includes dataobjects to hold types for HTTP objects,like Request, Response,
#   Error
#
#   If module doesnt grow to big then it will include function run_tests(),
#   which will run simple test cases to control correctness of defined
#   objects.
#------------------------------------------------------------------------------

type URIScheme
    #HTTP scheme: scheme://host:port/path?searchpart
    #/;? are reserved in path, seachpart
    scheme      :: String
    domain      :: String
    port        :: Int #default value is 80
    path        :: Tuple
    query       :: Tuple
    fragment    :: String #TODO: which types it can take
end


type Request
    url                    :: String    #address
    method                 :: String    #string of request method
    params                 :: Tuple #list of tuples to hold arguments of given URI 
    data                   :: Tuple #list of tuples to hold values of form
    allow_redirects        :: Bool

    Request(url :: String) = new(url, "GET", (), (), false)
    Request(url :: String,method :: String) = new(url, method, (), (), false) 
    Request(url :: String, params :: Tuple) = new(url, "GET", params, (), false)

    function Request(url, method, params, data, allow_redirects)
        
        new(url, method, params, data, allow_redirects)
    end
end

type Response
    status_code :: Int
    url         :: String
    headers     :: HashTable
    content     :: String
    error       :: String

end

#TODO: export test cases into specific file
function test_requests_object()
    
    test_url = "http://www.julialang.org"
    #test does default values works
    r1 = Request(test_url)
    print("$(r1.url) == $test_url : ")
    (r1.url == test_url) ? println("OK") : println("FAILED")
    assert(r1.method == "GET")
    assert(r1.allow_redirects == false)
    
end

function run_tests()

    test_requests_object()
    println("OK...All tests runned successfully.")
end

run_tests() #comment it out.
