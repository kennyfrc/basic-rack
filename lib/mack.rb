require 'webrick'

module Mack
  class Server
    attr_reader :options, :app, :server

    def initialize(options = nil)
      @options = options
      @app = @options[:app]
      @server = Mack::Adapter.get(@options[:server])
    end

    def self.start(options)
      new(options).start
    end

    def start
      app

      # captures signals, which are software interrupts
      #  https://www.tutorialspoint.com/unix/unix-signals-traps.htm
      trap(:INT) do
        if server.respond_to?(:shutdown)
          server.shutdown
        else
          exit
        end
      end

      server.run(app, **options)
    end
  end

  class Adapter
    def self.get(server)
      case server
      when 'webrick' then Mack::Adapter::WEBrick
      else
        raise "Unknown server: #{server}"
      end
    end

    class WEBrick < ::WEBrick::HTTPServlet::AbstractServlet
      def self.run(app, **options)
        options[:BindAddress] = options[:host] ? options[:host] : "localhost"
        options[:Port] = options[:port] ? options[:port] : 8080

        @server = ::WEBrick::HTTPServer.new(options)
        @server.mount "/", Mack::Adapter::WEBrick, app
        @server.start
      end

      def initialize(server, app)
        super server
        @app = app
      end

      def self.shutdown
        if @server
          @server.shutdown
          @server = nil
        end
      end

      def service(req, res)
        env = req.meta_vars
        env.delete_if { |k, v| v.nil? }

        # update enrironment with custom mack stuff if
        #   you'd like
        env.update({
          "MACK_VERSION"     => "0.0.1"
        })

        # apps should return an array with 3 elements
        #  [status, headers, body]
        status, headers, body = @app.call(env)
        res.status = status.to_i
        body.each { |part|
          res.body << part
        }
      end
    end
  end
end
