require 'magic_server'
require 'magic_server/server_constants'
require 'rack'
include MagicServer

module Rack
  module Handler
    class MagicServer < MagicServer::Servlet

      attr_accessor :server, :app

      def self.run(app, options={})
        puts 'inside run ' + app.class.to_s
        @app = app
        @server = MagicServer::Server.new
        @server.mount('/', Rack::Handler::MagicServer.new(app))
        @server.start
      end 

      def initialize(app = @app)
        puts caller(4).to_s
        puts 'instantiated in init ' + app.class.to_s
        @app = app
      end 

      def do_GET(session, request) 
        view = ::File.open('lib/rack/handler/test.html', 'r').read
        begin
          a = @app.call(build_env(request))
        rescue Exception => e
          puts e.to_s
        end 
        response = ''
        response << MagicServer::HTTP_SUCCESS
        response << ::MagicServer::content_type(MagicServer::HTML_TYPE)
        response << view
        session.print response
      end 

      def do_POST(session, request)
      end 

      def build_env(request)
        r = {}
        begin
          r['REQUEST_METHOD'] = request['Request-Line'].split(' ')[0]
          r['PATH_INFO'] = request[:path] || ''
          # Not sure how to use this attribute
          r['SCRIPT_NAME'] = ''

          rack_input = StringIO.new(request['Body'] || '') 
          # Add rack requirements
          r.update({"rack.version" => Rack::VERSION,
                   "rack.input" => rack_input,
                   "rack.errors" => $stderr,

                   "rack.multithread" => true,
                   "rack.multiprocess" => false,
                   "rack.run_once" => false,

                   "rack.url_scheme" => "http",

                   "rack.hijack?" => true,
                   "rack.hijack" => lambda { raise NotImplementedError, "only partial hijack is supported."},
                   "rack.hijack_io" => ''
          })
          # Add http fields
          r.update({ 'HTTP_HOST' => request['Host'],
                   'HTTP_CONNECTION' => request['Connection'],
                   'HTTP_ACCEPT' => request['Accept'],
                   'HTTP_USER_AGENT' => request['User-Agent'],
                   'HTTP_ACCEPT_ENCODING' => request['Accept-Encoding'],
                   'HTTP_ACCEPT_LANGUAGE' => request['Accept-Language'],
                   'HTTP_COOKIE' => request['Cookie'],
                   'HTTP_REFERER' => request['Referer'],
          })
        rescue Exception => e
          puts e.to_s
        end 
        r
      end 
    end 
  end 
end 


