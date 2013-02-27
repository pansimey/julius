# coding: utf-8

require 'eventmachine'

class FakeJulius
  class Server < EM::Connection
    def connection_completed
    end

    def receive_data(data)
      send_data(data.chomp + "です。\n")
    end

    def unbind
    end
  end

  def start
    EM.run do
      EM.start_server('localhost', 10500, Server)
    end
  end
end
