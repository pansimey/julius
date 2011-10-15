require 'socket'
require 'rexml/document'

class Julius
  def initialize(arg = {})
    raise ArgumentError, 'you need :model_path' unless arg[:model_path]
    arg = { encoding: 'u', host: 'localhost', port: 10500 }.merge(arg)
    encoding_str = { u: 'UTF-8', e: 'EUC-JP', s: 'Shift_JIS' }
    encoding = encoding_str[arg[:encoding].chr.downcase.intern]
    raise ArgumentError, 'not supported encodings' unless encoding
    fork{ `julius -C #{arg[:model_path]} -charconv EUC-JP #{encoding} -module` }
    @julius_socket = nil
    until @julius_socket
      begin
        @julius_socket = TCPSocket.new(arg[:host], arg[:port])
      rescue
        sleep 1
      end
    end
  end

  def start
    source = ''
    while true
      ret = IO::select([@julius_socket])
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
    @julius_socket.send("DIE\n", 0)
  end

  def pause
    @julius_socket.send("PAUSE\n", 0)
  end

  def terminate
    @julius_socket.send("TERMINATE\n", 0)
  end

  def resume
    @julius_socket.send("RESUME\n", 0)
  end
end
