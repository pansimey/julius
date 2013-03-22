# coding: utf-8

require 'rspec'
require 'julius'

describe Julius::Message do
  context 'when initialized with XML "<STARTPROC/>"' do
    subject { message = Julius::Message.init('<STARTPROC/>') }
    it { should be_an_instance_of(Julius::Message::Startproc) }
    it { should respond_to :name }
    its(:name){ should eq :STARTPROC }
  end

  context 'when initialized with unknown XML' do
    subject { lambda { Julius::Message.init('<FOO/>') } }
    it { should raise_error Julius::Message::ElementError }
  end
end

describe Julius::Message::Recogout do
  before do
    @xml = <<EOS # validなXMLでない
<RECOGOUT>
  <SHYPO RANK="1" SCORE="-3214.712891">
    <WHYPO WORD="" CLASSID="<s>" PHONE="silB" CM="0.244"/>
    <WHYPO WORD="送れ" CLASSID="送れ:オクレ:送れる:239" PHONE="o k u r e" CM="0.198"/>
    <WHYPO WORD="ます" CLASSID="ます:マス:ます:146" PHONE="m a s u" CM="0.723"/>
    <WHYPO WORD="か" CLASSID="か:カ:か:72" PHONE="k a" CM="0.411"/>
    <WHYPO WORD="？" CLASSID="？:？:？:5" PHONE="sp" CM="0.111"/>
    <WHYPO WORD="" CLASSID="</s>" PHONE="silE" CM="1.000"/>
  </SHYPO>
</RECOGOUT>
EOS
    @message = Julius::Message.init(@xml)
  end
  subject { @message }
  it { should respond_to :each }
  it { should respond_to :first }
  it { should respond_to :sentence }
  its(:sentence){ should eq '送れますか？' }
  context 'each' do
    it do
      expect {|block| @message.each(&block) }.to yield_control
    end
    it do
      expect {|block| @message.each(&block) }.to yield_with_args(
        Julius::Message::Recogout::Shypo)
    end
  end
  context 'first' do
    subject { @message.first }
    it { should be_an_instance_of Julius::Message::Recogout::Shypo }
    context 'each' do
      # it do
      #   expect {|block| @message.first.each(&block) }.to yield_control
      # end
      it do
        expect {|block| @message.first.each(&block) }.to yield_successive_args(
          Julius::Message::Recogout::Shypo::Whypo,
          Julius::Message::Recogout::Shypo::Whypo,
          Julius::Message::Recogout::Shypo::Whypo,
          Julius::Message::Recogout::Shypo::Whypo,
          Julius::Message::Recogout::Shypo::Whypo,
          Julius::Message::Recogout::Shypo::Whypo)
      end
    end
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
    @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
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
