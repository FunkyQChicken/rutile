$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rutile"

require "minitest/autorun"

def get_test_files(arr)
    testfiles = "./test/testfiles/"
    return arr.map {|str| testfiles + str}
end
