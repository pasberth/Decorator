#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'decorator/only'

class Module

    decorator
    def kwargsable func, default_args={}, &default_blk
        params = func.parameters
        params_nonblock = params.reject { |i| i[0] == :block }
        xs = params_nonblock.map { |i| i[1] }
        ->(*args, &blk) do

            if args.last.respond_to? :to_hash
                kwargs = args.pop.to_hash
            else
                kwargs = {}
            end

            args.fill nil, args.length, params_nonblock.length - args.length - 1

            default_args.each do |key, default|
                next unless xs.include? key
                i = xs.index(key)
                if args[i].nil? then args[i] = default
                end
            end

            blk = default_blk if blk.nil?

            kwargs.each do |key, arg|
                next unless xs.include? key
                kwargs.delete key
                args[xs.index(key)] = arg
            end

            func.call *args, kwargs, &blk
        end
    end
end