require 'socket'
require 'rexml/document'

class Julius
  def self.kill(instance)
    lambda{ Process.kill 'KILL', instance.pid }
  end

  def initialize(arg = {})
    raise ArgumentError, 'use keyword argument' unless arg.class == Hash
    raise ArgumentError, 'you need :model_path' unless arg[:model_path]
    arg = { encoding: 'u', host: 'localhost', port: 10500 }.merge(arg)
    encoding_str = { u: 'UTF-8', e: 'EUC-JP', s: 'Shift_JIS' }
    encoding = encoding_str[arg[:encoding].chr.downcase.intern]
    raise ArgumentError, 'not supported encodings' unless encoding
    @pid = spawn(
      "julius -C #{arg[:model_path]} -charconv EUC-JP #{encoding} -module",
      out: '/dev/null')
    @socket = nil
    until @socket
      begin
        @socket = TCPSocket.new(arg[:host], arg[:port])
      rescue
        sleep 1
      end
    end
    ObjectSpace.define_finalizer(self, self.class.kill(self))
  end
  attr_reader :pid

  def start
    source = ''
    while true
      ret = IO::select([@socket])
      ret[0].each do |socket|
        source << socket.recv(65535)
        next unless source[/\.\n$/]
        source.gsub!(/CLASSID="<(\/?s)>"/, "CLASSID=\"&lt;#{$1}&gt;\"")
        xmls = source.split(/\.\n/)
        xmls.each do |xml|
          next unless xml[/^<RECOGOUT/]
          document = REXML::Document.new(xml)
          elements = document.root.get_elements('SHYPO/WHYPO')
          segments = elements.map{|item| item.attribute('WORD').value }
          sentence = segments.join
          yield(sentence) if sentence.size > 0
        end
        source.clear
      end
    end
  end

  def die
    @socket.send("DIE\n", 0)
  end

  def pause
    @socket.send("PAUSE\n", 0)
  end

  def terminate
    @socket.send("TERMINATE\n", 0)
  end

  def resume
    @socket.send("RESUME\n", 0)
  end
end
