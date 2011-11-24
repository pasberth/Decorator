# -*- coding: utf-8 -*-

class Object

  private

  def decorators
    @decorators ||= []
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
          func = res if res.respond_to?(:to_proc) || Method === res || UnboundMethod === res
        end
      end
      next if origin.equal? func
      if func.respond_to? :to_proc
        define_singleton_method funcname, &func
      else
        define_singleton_method funcname, func
      end
    end
  end
end


class Module

  private

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
        _f = case _f
             when UnboundMethod then _f.bind self
             when Method then _f
             end
        _after = ->(_func, *_args, &_blk) do # the _after is called when created the a_function
          _new_method = ->(*__args, &__blk) do # new function replaced to the a_function
            _func = case _func
                    when UnboundMethod then _func.bind self
                    when Method then _func
                    end
            res = _f.call _func, *args, &blk
            if res.respond_to?(:to_proc)
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
          func = res if res.respond_to?(:to_proc) || Method === res || UnboundMethod === res
        end
      end
      next if origin.equal? func
      if func.respond_to? :to_proc
        define_method funcname, &func
      else
        define_method funcname, func
      end
    end
  end
end

class Module

  decorator
  def wrap func, *args, &blk
    puts "wrapped!"
    proc { func.call *args, &blk }
  end
end
  
module Kernel

  wrap
  def wrapped *args, &blk
    puts "IN!"
  end

  decorator
  def dec func, *args, &blk
    proc { puts "deced!" }
  end
end

wrapped
wrapped
# wrapped!
# IN!
# IN!

self.instance_eval do
  dec
  def self.m *args, &blk
    puts "in!"
  end
end

self.m
self.m
# deced!
# deced!
