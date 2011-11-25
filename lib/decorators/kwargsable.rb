#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'decorator'

class Module

  decorator
  def kwargsable func, defaults={}
    params = func.parameters
     xs = params.map { |i| i[1] }
    ->(*args, &blk) do

      if args.last.respond_to? :to_hash
        kwargs = args.pop
      else
        kwargs = {}
      end

      defaults.each do |key, default|
        next unless xs.include? key
        i = xs.index(key)
        if args[i].nil? then args[i] = default
        end
      end

      kwargs.each do |key, arg|
        next unless xs.include? key
        kwargs.delete key
        args[xs.index(key)] = arg
      end

      func.call *args, kwargs, &blk
    end
  end
end