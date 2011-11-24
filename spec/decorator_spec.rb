require File.dirname(__FILE__) + "/../lib/decorator"
require "tempfile"

describe "decorator" do


  it "define logging decorator" do

    temp = Tempfile.new "logging decorator"

    TestClass = Class.new do

      decorator
      def self.logging func, file
        ->(*args, &blk) do
          file.puts "called #{func.name}"
          func.call(*args, &blk).tap do |res|
            file.puts "returned #{res}"
          end
        end
      end

      logging(temp)
      def function arg
        return arg
      end

    end

    ins = TestClass.new
    ins.function("case one").should == "case one"
    temp.seek 0
    temp.read.should == "called function\nreturned case one\n"

    temp.seek 0

    ins.function("case two").should == "case two"
    temp.seek 0
    temp.read.should == "called function\nreturned case two\n"

  end

  it "dual logging decorator" do

    temp = Tempfile.new "logging decorator"

    TestClass = Class.new do

      decorator
      def self.logging func, file
        ->(*args, &blk) do
          file.puts "called #{func.name}"
          func.call(*args, &blk).tap do |res|
            file.puts "returned #{res}"
          end
        end
      end

      logging(temp)
      logging(temp)
      def function arg
        return arg
      end

    end

    ins = TestClass.new
    ins.function("case one").should == "case one"
    temp.seek 0
    temp.read.should == "called function\ncalled function\nreturned case one\nreturned case one\n"

  end

  it "define logging decorator to Class" do

    temp = Tempfile.new "logging decorator"

    class Class
      decorator
      def logging func, file
        ->(*args, &blk) do
          file.puts "called #{func.name}"
          func.call(*args, &blk).tap do |res|
            file.puts "returned #{res}"
          end
        end
      end
    end

    TestClass = Class.new do


      logging(temp)
      def function arg
        return arg
      end

    end

    ins = TestClass.new
    ins.function("case one").should == "case one"
    temp.seek 0
    temp.read.should == "called function\nreturned case one\n"

  end

end
