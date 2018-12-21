$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rutile"

require "minitest/autorun"


TESTFILES = "./test/testfiles/"

def get_test_file(str)
    return TESTFILES + str
end

def get_test_files(arr)
    return arr.map {|str| get_test_file str}
end
