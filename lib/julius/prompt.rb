class Julius
  class Prompt
    class NoCommandError < StandardError; end

    def initialize(socket)
      @socket = socket
    end

    def method_missing(name, *args)
      command = eval("Command::#{name.capitalize}").new(*args)
      @socket.puts(command.to_s)
    rescue NameError
      raise NoCommandError, "the command '#{name}' is not supported."
    end
  end
end
