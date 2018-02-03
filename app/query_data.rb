require File.expand_path('../base_require', __FILE__)

class QueryData < BaseRequire
	include HttpRequestCalm

	def initialize(path)
		@url = URI(path)
		@query_params = {serviceName: 'cqlQuery'}
		@result = {result: false, return_info: '', return_code: '', data: []}
	end

	def query_data(apiname, binding, sql)
		@query_params[:objectApiName] = apiname
		@query_params[:binding] = binding
		@query_params[:expressions] = sql

		@url.query = URI.encode_www_form(@query_params)
		request = Net::HTTP::Get.new(@url.request_uri)
		request["Accept"] = 'application/json'

		# http = Net::HTTP.new(@url.host, @url.port)
		#
		# http.request(request) do |res|
		# 	case res
		# 	when Net::HTTPOK
		# 		json_data = JSON.parse(res.body)
		#
		# 		@result[:result] = json_data["result"]
		# 		if @result[:result]
		# 			@result[:data] = json_data["data"][0]
		# 			@result[:return_code] = json_data["returnCode"]
		# 		else
		# 			@result[:return_info] = json_data["returnInfo"]
		# 		end
		# 	else
		# 		@result
		# 	end
		# end

		http_request_calm(@url, request) do |res|
			case res
			when Net::HTTPSuccess
				json_data = JSON.parse(res.body)

				@result[:result] = json_data["result"]
				if @result[:result]
					@result[:data] = json_data["data"][0]
					@result[:return_code] = json_data["returnCode"]
				else
					@result[:return_info] = json_data["returnInfo"]
				end
			else
				@result
			end
		end

		@result
	end
end