# frozen_string_literal: true

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"
  # https://github.com/ruby/ruby/blob/trunk/gems/bundled_gems#L2
  gem "minitest"
end

class Foo
  # def play
  #   "play"
  # end
end

require 'minitest/autorun'

class FooTest < Minitest::Test
  # def test_foo
  #   assert_equal "play", Foo.new.play
  # end
end
