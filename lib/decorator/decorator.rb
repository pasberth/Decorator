#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module Decorator
    VERSION = "0.0.1"
end

class Object

  private

    def decorators
        @decorators ||= []
    end

    def add_decorator _f, *args, &blk
        _f = case _f
             when UnboundMethod then _f.bind self
             when Method then _f
             end
        _after = ->(_func, *_args, &_blk) do # the _after is called when created the a_function
            # selfがこのクラスまたはモジュールのインスタンスになるようにinstance_execなどをすること
            # define_methodなどでもselfは正しくなるのでそれでok
            _new_method = ->(*__args, &__blk) do # new function replaced to the a_function
                _func = case _func
                        when UnboundMethod then _func.bind self
                        when Method then _func
                        end
                res = _f.call _func, *args, &blk
                if res.respond_to? :to_proc
                    define_singleton_method _func.name, &res
                    send _func.name, *__args, &__blk
                elsif Method === res || UnboundMethod === res
                    define_singleton_method _func.name, res
                    send _func.name, *__args, &__blk
                end
            end
            return _new_method
        end
        decorators << [_after, args, blk]
        true
    end

    alias decoratable_original_singleton_method_added singleton_method_added

    def singleton_method_added funcname
        decoratable_original_singleton_method_added(funcname).tap do
            next if decorators.empty?
            origin = method funcname
            func = origin

            until decorators.empty?
                decorators.pop.tap do |f, args, blk|
                    res = f.call func, *args, &blk
                    if res.respond_to? :to_proc
                        define_singleton_method funcname, &res
                        func = method func.name
                    elsif Method === res || UnboundMethod === res
                        define_singleton_method funcname, res
                        func = method func.name
                    end
                end
            end
        end
    end
end


class Module
    # デコレータを作成するデコレータです。デコレータを作る場合は通常これをデコレータとします。
    # example:
    #    class Module
    #      decorator
    #      def wrap func, *args, &blk
    #        puts "wrapped!"
    #        proc { func.call *args, &blk }
    # デコレータの第一引数は必ずMethodです。
    # この場合のwrapはデコレータとして使用できます。
    #    class TestClass
    #      wrap
    #      def wrapped *args, &blk
    #        puts "IN!"
    # もしデコレータに引数を渡した場合、それはすべてデコレータに一緒に渡されます。
    #    class TestClass
    #      wrap(*example_args)
    #      def wrapped *args, &blk
    #        puts "IN!"
    # => ↓のargsにexample_argsが渡される
    #      def wrap func, *args, &blk
    #        puts "wrapped!"
    #        proc { func.call *args, &blk }
    # デコレータの戻り値がProcである場合、関数はそのProcに置き換えられます。
    # たとえばこの場合、wrappedはwrap内のprocに置き換えられます。
    def decorator *args, &blk

        # for example,
        # class Example
        #   decorator
        #   def self.logging
        #   ...
        # 
        #   logging
        #   def a_function
        #   ...
        after = ->(_f, *_a, &_b) do # the after is called when created the self.logging
            new_method = ->(*args, &blk) do # new function replaced to the self.logging
                add_decorator _f, *args, &blk
            end

            return new_method
        end

        decorators << [after, args, blk]
        true
    end


    alias decoratable_original_method_added method_added

    def method_added funcname
        decoratable_original_method_added(funcname).tap do
            next if decorators.empty?
            origin = instance_method funcname
            func = origin

            until decorators.empty?
                decorators.pop.tap do |f, args, blk|
                    res = f.call func, *args, &blk
                    if res.respond_to? :to_proc
                        define_method funcname, &res
                        func = instance_method func.name
                    elsif Method === res || UnboundMethod === res
                        define_method funcname, res
                        func = instance_method func.name
                    end
                end
            end
        end
    end
end