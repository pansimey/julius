require 'socket'
require 'julius/version'
require 'julius/message'
require 'julius/command'
require 'julius/prompt'

class Julius
  def initialize(arg = {})
    @host = arg[:host] || 'localhost'
    @port = arg[:port] || 10500
  end

  def each_message
    return self.to_enum(__method__) unless block_given?
    socket = TCPSocket.new(@host, @port)
    prompt = Prompt.new(socket)
    xml_enum(socket).each do |xml|
      yield(Message.init(xml), prompt)
    end
    self
  end

  private
  def xml_enum(socket)
    Enumerator.new do |yielder|
      while line = socket.readline(".\n")
        yielder << line.force_encoding('UTF-8').sub(/\.\n$/, '')
      end
    end
  end
end
