require 'socket'
require 'rexml/document'

class Julius
  module Message
    class StartProc
    end

    class StopProc
    end

    class StartRecog
    end

    class EndRecog
    end

    class Input
    end

    class InputParam
    end

    class Gmm
    end

    class RecogOut
    end

    class RecogFail
    end

    class Rejected
    end

    class GraphOut
    end

    class GramInfo
    end

    class SysInfo
    end

    class EngineInfo
    end

    class Grammar
    end

    class RecogProcess
    end
  end

  def initialize(path_of_model, encoding = 'u')
    case encoding[/^./]
    when 'u', 'U'
      encoding_to = 'UTF-8'
    when 'e', 'E'
      encoding_to = 'EUC-JP'
    when 's', 'S'
      encoding_to = 'Shift_JIS'
    else
      raise 'not supported encodings'
    end
    fork do
      `julius -C #{path_of_model} -charconv EUC-JP #{encoding_to} -module`
    end
    @julius_socket = nil
    until @julius_socket
      begin
        @julius_socket = TCPSocket.new('localhost', 10500)
      rescue
        sleep 1
      end
    end
  end

  def start
    source = ''
    loop do
      ret = IO::select([@julius_socket])
      ret[0].each do |socket|
        source << socket.recv(65535)
        if source[/\.\n$/]
          source.sub!(/\.\n$/){''}
          xmls = source.split(/\.\n/)
          xmls.each do |xml|
            xml.gsub!(/CLASSID="<(\/?s)>"/){"CLASSID=\"&lt;#{$1}&gt;\""}
            begin
              document = REXML::Document.new(xml)
            rescue
              next
            end
            next unless document.root
            case element_name = document.root.name
            when 'STARTPROC'
            when 'STOPPROC'
            when 'STARTRECOG'
            when 'ENDRECOG'
            when 'INPUT'
              case status_value = document.root.attribute('STATUS').value
              when 'LISTEN'
              when 'STARTREC'
              when 'ENDREC'
              else
              end
            when 'INPUTPARAM'
            when 'GMM'
            when 'RECOGOUT'
              elements = document.root.get_elements('SHYPO/WHYPO')
              segments = elements.map{|element| element.attribute('WORD').value}
              sentence = segments.join
              if sentence.size > 0
                yield(sentence)
              end
            when 'RECOGFAIL'
            when 'REJECTED'
            when 'GRAPHOUT'
            when 'GRAMINFO'
            when 'SYSINFO'
            when 'ENGINEINFO'
            when 'GRAMMAR'
              case status_value = document.root.attribute('STATUS').value
              when 'RECEIVED'
              when 'READY'
              when 'ERROR'
              else
              end
            when 'RECOGPROCESS'
            else
            end
          end
          source = ''
        end
      end
    end
  end

  def status
  end

  def die
    @julius_socket.send("DIE\n", 0)
  end

  def version
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

  def current_process(instance)
  end

  def shift_process
  end

  def add_process(jconf_path)
  end

  def del_process(instance)
  end

  def list_process
  end

  def deactivate_process(instance)
  end

  def activate_process(instance)
  end
end
