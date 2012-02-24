#------------------------------------------------------------------------------
#httputils.j
#
# Includes utilfunctions, which helps us to build url, split url into elements 
# etc.
#------------------------------------------------------------------------------


function encode_args(args :: Tuple)
    #builds correct search path of URI from given tuple of arguments
    #usage:
    # >>> args = (("q", "search term1", "search term2"), ("lang", "en"))
    # >>> encode_args(args)

end

function decode_args(url :: String)
    # decompose search path from args
    # usage:
    # >>> url = "http://julialang.org?q=Search%20Term&lang=en&q=Search%20Term2"
    # >>> decode_args(url)

end

function split_uri(uri)
    # splits uri string into components and return URI type-object
end

function build_uri(url :: String, args :: Tuple)
    # builds correct HTTP url from given args
end

