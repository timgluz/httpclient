#------------------------------------------------------------------------------
#httputils.j
#
# Includes utilfunctions, which helps us to build url, split url into elements 
# etc.
#------------------------------------------------------------------------------


#-- CONSTANTS -----------------------------------------------------------------

#Chars that are allowed in a URI but dont have a reserved purpose are called as unreserved

const ALPHA = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const DIGIT = b"0123456789"
const UNRESERVED = append(ALPHA, DIGIT, b"-._~") 

const GEN_DELIMS = b"\:\/\?\#\[\]\@" # delimiters of the generic URI components .
const SUB_DELIMS = b"\$\&\'\!()*+,;="
const RESERVED = append(GEN_DELIMS, SUB_DELIMS)



#-- HELPER FUNCTIONSIONS ------------------------------------------------------

head = lst -> lst[1]    #return first element of list
tail = lst -> (length(lst)> 1) ? lst[2:end] : [] #returns all elements except the first one


#-- PUBLIC FUNCTIONS ----------------------------------------------------------

function encode_string(val)
    encoded_chars = String[]

    for chr in val
        #if it's reserved character or 2byte Unicode character then encode it
        if contains(UNRESERVED, head(b"$chr"))
            push(encoded_chars, "$chr")# keepit same
        else 
            #if contains(RESERVED, head(b"$chr")) == true || length(b"$chr") == 2 #TODO: do i need that??
            new_enc_val = map(ch -> "%$(uppercase(hex(ch)))", b"$chr") #turn bytearray to array of encoded characters.
            push(encoded_chars, join(new_enc_val, "")) #concanate encoded vals to one string and push into encoded_vals

        end
    end

    return join(encoded_chars, "")
end

function encode_args(queries::Tuple)
    #builds correct search path of URI from given tuple of arguments
    # -------------------------------------------------------------------------
    # Notes from RFC3986, http://www.ietf.org/rfc/rfc3986.txt
    # additional readings:  http://en.wikipedia.org/wiki/Percent-encoding
    #
    # Octects must be encoded:
    #   1. they have no corresponding graphic character within the US-ASCII coded
    #       character set
    #   2. the use of the character is unsafe
    #   3. the corresponding character is reserved for some other interpretation
    #       within the particular URL scheme.
    #--------------------------------------------------------------------------

    # Usage:
    # >>> args = (("q", "search term1", "search term2"), ("lang", "en"))
    # >>> encode_args(args)
    encoded_queries = String[] 
    for query in queries
        #-- encode vals
        encoded_vals = String[]
        for item in query
            if isa(item, Real)
                #-- encode numbers
                push(encoded_vals, "$item")
            else
                #-- encode strings 
                push(encoded_vals, encode_string(item)) #add encoded string into encoded vals
            end
        end
        #concanates query=val pairs into one string and pushes it into final stack called encoded_queries
        pairs = join(["$(head(encoded_vals))=$val" | val in tail(encoded_vals)], "&")
        push(encoded_queries, pairs) 
    
    end
    
    return join(encoded_queries, "&") #before returning concanate part of queries into one string

end

function decode_args(url :: String)
    # decompose search path from args
    # usage:
    # >>> url = "http://julialang.org?q=Search%20Term&lang=en&q=Search%20Term2"
    # >>> decode_args(url)
    return false
end

function split_uri(uri)
    # splits uri string into components and return URI type-object
    return false
end

#TODO: reads standards about host encoding
function build_uri(request)
    # builds correct HTTP url from given request object
    uri = "$(request.url)?$(encode_args(request.params))"
    return uri 
end

#-- TEST FUNCTIONs ------------------------------------------------------------
import("httptypes")

function test_runner(func, test_data, expected_val, test_title::String)
    println("\n-----------------------------------------------")
    println("Running test: $test_title")
    val =  func(test_data) 

    if (typeof(val) == typeof(expected_val)) && (val == expected_val) 
        success = true
    else
        success = false
    end

    println("Result: `$val` == `$expected_val` : $success")
    return success 
end

function test_encoding_args()
    #just learnt to handle hammer and i see everywhere nails... :D (my passion about map)
    #for expected_val i used service: http://www.urlencoder.org/

    println("#-- Testing encoding arguments of url query:")
    test_cases = (
        ((("q", "single arg with spaces"),), "q=single%20arg%20with%20spaces", "Test simple arg" ),
        ((("q1", "a", "b", "c"), ("q2", "d")), "q1=a&q1=b&q1=c&q2=d", "Test with multiple query-keys."),
        ((("lat", "1.012"), ("long", "154.221")), "lat=1.012&long=154.221", "Testing with numerals as string"),
        ((("lat", 1.012), ("long", 154.221)), "lat=1.012&long=154.221", "Testing with numbers"),
        ((("q", "Jää-august jõllitas vastu ämblik Ülo."),), 
        "q=J%C3%A4%C3%A4-august%20j%C3%B5llitas%20vastu%20%C3%A4mblik%20%C3%9Clo.", "testing with unicode literals."),
        ((("expr", "(x+y)/2.0*z^3"),), "expr=%28x%2By%29%2F2.0%2Az%5E3", "Test with mathematical expressions"),
    )
    test_results = map(test_run -> test_runner(encode_args, test_run[1], test_run[2], test_run[3]), test_cases)  

    return test_results
end

function test_build_uri()
    println("#-- Testing url building")
    
    request = Request("http://httpbin.org/get", (("q", 1), ("expr", "(x+y)/2.0*z^3")))
    val = build_uri(request)

    test_runner(build_uri, request, "http://httpbin.org/get?q=1&expr=%28x%2By%29%2F2.0%2Az%5E3", "Testing simple uri building.")
end

function run_tests()
    println("Running tests...")
    test_encoding_args()
    test_build_uri()
    return true
end

run_tests()

