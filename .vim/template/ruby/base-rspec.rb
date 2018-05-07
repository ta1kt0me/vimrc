# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "rspec"
end

require "rspec/autorun"

class Foo
  # def play
  #   "play"
  # end
end

RSpec.describe Foo do
  # describe "#play" do
  #   it { expect(Foo.new.play).to eq("play") }
  # end
end
