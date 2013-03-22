# coding: utf-8

require 'rspec'
require 'julius'

describe Julius::Message do
  context 'init with <STARTPROC/>' do
    it 'instance should be one of Julius::Message::Startproc' do
      message = Julius::Message.init('<STARTPROC/>')
      message.should be_an_instance_of(Julius::Message::Startproc)
    end
  end

  context 'init with unknown xml' do
    subject { lambda { Julius::Message.init('<FOO/>') } }
    it { should raise_error Julius::Message::ElementError }
  end
end

describe Julius::Command::Status do
  subject { @status = Julius::Command::Status.new }
  its(:to_s){ should eq 'STATUS' }
end

describe Julius::Command::Addprocess do
  subject { @addprocess = Julius::Command::Addprocess.new('/path/to/jconf') }
  its(:to_s){ should eq 'ADDPROCESS /path/to/jconf' }
end

describe Julius::Prompt do
  before do
    @server_socket, fake_socket = IO.pipe
    @prompt = Julius::Prompt.new(fake_socket)
  end

  context 'status' do
    it 'server should receive command "STATUS"' do
      @prompt.status
      @server_socket.gets.chomp.should eq 'STATUS'
    end
  end

  context 'unknown command: foo' do
    subject { lambda { @prompt.foo } }
    it { should raise_error Julius::Prompt::NoCommandError }
  end
end

describe Julius do
  before do
    allow_message_expectations_on_nil
    @socket = IO.popen('-')
    @socket.stub!(:readline).and_return('<STARTPROC/>', nil)
    TCPSocket.should_receive(:new)
             .with('localhost', 10501)
             .and_return(@socket)
    @julius = Julius.new(port: 10501)
  end
  context 'each_message' do
    it do
      expect {|block| @julius.each_message(&block) }.to yield_control
    end
    it do
      expect {|block| @julius.each_message(&block) }.to yield_with_args(
        Julius::Message::Startproc,
        Julius::Prompt)
    end
  end
end
