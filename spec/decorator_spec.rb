require File.dirname(__FILE__) + "/../lib/decorator"
require "tempfile"

class TestClass; end

describe "decorator" do


  it "define logging decorator" do

    TestClass.class_eval do

      decorator
      def self.logging func, file
        p func, file
        ->(*args, &blk) do
          file.puts "called #{func.name}"
          func.call(*args, &blk).tap do |res|
            file.puts "returned #{res}"
          end
        end
      end

      temp = Tempfile.new "logging decorator"

      logging(temp)
      def function arg
        p arg
        return arg
      end

      ins = TestClass.new
      ins.function("case one")
      temp.seek 0
      temp.read.should == "called function\nreturned case one\n"
    end


  end

end
