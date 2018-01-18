require '/Users/chai/workspace_custom_insert/app/base_require'

class QueryData < BaseRequire
	def initialize(path)
		@url = URI(path)
		@query_params = {serviceName: 'cqlQuery'}
		@result = {result: false, return_info: '', return_code: '', data: []}
	end

	def query_data(apiname, binding, sql)
		@query_params[:objectApiName] = apiname
		@query_params[:binding] = binding
		@query_params[:expressions] = sql

		http = Net::HTTP.new(@url.host, @url.port)
		@url.query = URI.encode_www_form(@query_params)
		request = Net::HTTP::Get.new(@url.request_uri)
		request["Accept"] = 'application/json'

		http.request(request) do |res|
			case res
			when Net::HTTPOK
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