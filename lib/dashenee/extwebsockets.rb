require 'net/http'
require 'sinatra'
require 'sinatra-websocket'
require 'dashenee/constants'
require 'dashenee/serversentevents'
require 'logger'

set :WSExtAuthToken , "token1"
set :WXExtRootURL , "http://localhost:4040/"

class WebSocketExt < EventsEngine
	register_engine EventsEngineTypes::WSEXT
	def initialize(type)
		@type=type
		@logger = Logger.new(STDERR)
	end	
	def send_event(id,body,target=nil)
		path= target.nil? ? "data/"+id : target+"/"+id
		body[:id]=id
		body[:updatedAt] ||= (Time.now.to_f * 1000).ceil
		body[:auth_token]=Sinatra::Application.settings.WSExtAuthToken
		uri = URI(URI.escape(Sinatra::Application.settings.WXExtRootURL+path))
		http = Net::HTTP.new(uri.host,uri.port)
		if uri.scheme.downcase == 'https' then
			http.use_ssl=true
			http.verify_mode=OpenSSL::SSL::VERIFY_NONE
		end
		response = http.post(uri.path,body.to_json)
		@logger.warn { response.inspect } if response.code.to_i >399
	end
end