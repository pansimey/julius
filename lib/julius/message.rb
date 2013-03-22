class Julius
  class Message
    class ElementError < StandardError; end

    class Startproc  < Message; end
    class Endproc    < Message; end
    class Stopproc   < Message; end # TODO マニュアルに存在しない謎要素
    class Startrecog < Message; end
    class Endrecog   < Message; end

    class Input < Message
      attr_reader :status, :time
    end

    class Inputparam < Message
      attr_reader :frames, :msec
    end

    class GMM < Message
      attr_reader :result, :cmscore
    end

    class Recogout < Message
      include Enumerable
      class Shypo < Message
        include Enumerable
        class Whypo < Message
          attr_reader :word, :classid, :phone, :cm
          def to_s
            @word
          end
        end

        def initialize(element)
          @whypo_list = element.elements.map do |element|
            Whypo.new(element)
          end
          super(element)
        end
        attr_reader :rank, :score

        def each(&block)
          return self.to_enum unless block_given?
          @whypo_list.each(&block)
          self
        end
      end

      def initialize(element)
        @shypo_list = element.elements.map do |element|
          Shypo.new(element)
        end
        super(element)
      end

      def each(&block)
        return self.to_enum unless block_given?
        @shypo_list.each(&block)
        self
      end

      def first
        @shypo_list.first
      end

      def [] nth
        @shypo_list[nth]
      end

      alias at []

      def sentence
        self.first.map{|whypo| whypo.to_s }.join
      end
    end

    class Recogfail < Message; end

    class Rejected < Message
      attr_reader :reason
    end

    class Graphout < Message; end
    class Graminfo < Message; end

    class Sysinfo < Message
      attr_reader :process
    end

    class Engineinfo < Message
      attr_reader :type, :version, :conf
    end

    class Grammar < Message
      attr_reader :status, :reason
    end

    class Recogprocess < Message; end

    def self.init(xml)
      document = REXML::Document.new(xml.gsub(/<(\/?)s>/){ "&lt;#{$1}s&gt;" })
      eval(document.root.name.capitalize).new(document.root)
    rescue NameError
      raise ElementError, "invalid XML element found: #{document.root.name}"
    end

    def initialize(element)
      element.attributes.each do |attribute|
        self.instance_variable_set("@#{attribute[0].downcase}", attribute[1])
      end
    end

    def name
      self.class.name.upcase[/[A-Z]+$/].intern
    end
  end
end
