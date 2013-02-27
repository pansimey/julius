# coding: utf-8

fake_bin = File.expand_path(File.dirname(__FILE__) + '/bin')
ENV['PATH'] = "#{fake_bin}:#{ENV['PATH']}"

require 'rspec'
require 'julius'

system 'fake_julius start'

describe Julius::Client do
end
describe Julius do
end

system 'fake_julius stop'
