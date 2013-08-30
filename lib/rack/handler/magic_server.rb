require 'magic_server'
require 'magic_server/server_constants'
include MagicServer

module Rack
  module Handler
    class MagicServer < MagicServer::Servlet
      def self.run(app, options={})
        server = MagicServer::Server.new
        server.mount('/', Rack::Handler::MagicServer.new(app))
        server.start
      end 

      def initialize(app = @app)
        @app = app
      end 

      def do_GET(session, request) 
        view = ::File.open('lib/rack/handler/test.html', 'r').read
        response = ''
        response << MagicServer::HTTP_SUCCESS
        response << ::MagicServer::content_type(MagicServer::HTML_TYPE)
        response << view
        puts response.inspect
        session.print response
      end 

      def do_POST(session, request)
      end 
    end 
  end 
end 


