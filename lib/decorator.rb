# -*- coding: utf-8 -*-

class Module

  private

  def decorators
    @decorators ||= []

  def decorator *args, &blk

    after = ->(_f, *_a, &_b) do

      new_method = ->(*args, &blk) do  # args が _args に渡される
        _after = ->(_func, *_args, &_blk) do  # blk が _blk に渡される
          _func = _func.bind(self) unless _func.respond_to? :to_proc
          return _f.bind(self).call _func, *_args, &_blk

        decorators << [_after, args, blk]
        true

      return new_method

    decorators << [after, args, blk]
    true


  alias decoratable_original_method_added method_added

  def method_added funcname
    decoratable_original_method_added(funcname).tap do
      next if decorators.empty?
      func = instance_method funcname

      until decorators.empty?
        decorators.pop.tap do |f, args, blk|
          func = f.call func, *args, &blk # to decorator/after when decorator
      if func.respond_to? :to_proc
        define_method funcname, &func

class Object

  private

  def decorators
    @decorators ||= []

  alias decoratable_original_singleton_method_added singleton_method_added

  def singleton_method_added funcname
    decoratable_original_singleton_method_added(funcname).tap do
      next if decorators.empty?
      func = method funcname

      until decorators.empty?
        decorators.pop.tap do |f, args, blk|
          func = f.call func, *args, &blk # to decorator/after when decorator
      if func.respond_to? :to_proc
        define_singleton_method funcname, &func

class Module

  decorator
  def wrap func, *args, &blk
    puts "wrapped!"
    proc { func.call *args, &blk }
  
module Kernel

  wrap
  def wrapped *args, &blk
    puts "IN!"

  decorator
  def dec func, *args, &blk
    proc { puts "deced!" }

wrapped
wrapped
# wrapped!
# IN!
# IN!

self.instance_eval do
  dec
  def self.m *args, &blk
    puts "in!"

self.m
self.m
# deced!
# deced!
