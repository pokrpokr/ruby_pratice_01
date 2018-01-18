require File.expand_path('../base_require', __FILE__)

class InsertData < BaseRequire
	def initialize(path)
		@url = URI(path)
		@params = {serviceName: 'insert'}
		@result = {result: false, return_info: '', oa_id: ''}
	end

	def insert_data(apiname, binding, additions)
		data = additions.to_json
		@params[:objectApiName] = apiname
		@params[:binding] = binding
		@params[:data] = data

		http = Net::HTTP.new(@url.host, @url.port)
		request = Net::HTTP::Post.new(@url)
		request.set_form_data(@params)
		request["Accept"] = 'application/json'

		http.request(request) do |res|
			case res
			when Net::HTTPOK
				json_data = JSON.parse(res.body)
				@result[:result] = json_data["result"]

				if @result[:result]
					@result[:oa_id] = json_data["data"]["ids"][0]["id"]
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