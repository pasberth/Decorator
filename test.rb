require './src/decorators'


module Kernel

  kwargsable(key1: "key1", key2: "key2", key3: "key3")
  def m key1, key2, key3, kwargs
    puts key1, key2, key3, kwargs

m(key2: 'passed_key2', key3: 'passed_key3')
