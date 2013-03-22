class Julius
  class Message
    class ElementError < StandardError; end

    class Startproc    < Message; end
    class Endproc      < Message; end
    class Startrecog   < Message; end
    class Endrecog     < Message; end
    class Input        < Message; end
    class Inputparam   < Message; end
    class GMM          < Message; end
    class Recogout     < Message; end
    class Recogfail    < Message; end
    class Rejected     < Message; end
    class Graphout     < Message; end
    class Graminfo     < Message; end
    class Sysinfo      < Message; end
    class Engineinfo   < Message; end
    class Grammar      < Message; end
    class Recogprocess < Message; end

    def self.init(xml)
      element = xml[/^<([A-Z]+)/, 1]
      eval(element.capitalize).new(xml)
    rescue NameError
      raise ElementError, "invalid XML element found: #{element}"
    end

    def initialize(xml)
      @xml = xml
    end
  end
end
