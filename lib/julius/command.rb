class Julius
  class Command
    class Status            < Command; end
    class Die               < Command; end
    class Version           < Command; end
    class Pause             < Command; end
    class Terminate         < Command; end
    class Resume            < Command; end
    class Currentprocess    < Command; end
    class Shiftprocess      < Command; end
    class Addprocess        < Command; end
    class Delprocess        < Command; end
    class Listprocess       < Command; end
    class Deactivateprocess < Command; end
    class Activateprocess   < Command; end
    class Graminfo          < Command; end
    class Changegram        < Command; end
    class Addgram           < Command; end
    class Delgram           < Command; end
    class Deactivategram    < Command; end
    class Activategram      < Command; end
    class Inputonchange     < Command; end
    class Syncgram          < Command; end
    class Addword           < Command; end

    def initialize(*args)
      @args = args
    end

    def to_s
      if @args.size > 0
        "#{name} #{@args.join(' ')}"
      else
        name
      end
    end

    private
    def name
      self.class.name.upcase[/[A-Z]+$/]
    end
  end
end
