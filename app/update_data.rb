require '/Users/chai/workspace_custom_insert/app/base_require'

class UpdateData < BaseRequire
	include HttpRequestCalm

	def initialize(path)
		@url = URI(path)
		@params = {serviceName: 'update'}
		@result = {result: false, return_info: '', return_code: ''}
	end

	def update_data(apiname, binding, additions)
		data = additions.to_json
		@params[:objectApiName] = apiname
		@params[:binding] = binding
		@params[:data] = data

		request = Net::HTTP::Post.new(@url)
		request.set_form_data(@params)
		request["Accept"] = 'application/json'

		# http.request(request) do |res|
		# 	case res
		# 	when Net::HTTPOK
		# 		json_data = JSON.parse(res.body)
		# 		@result[:result] = json_data["result"]
		#
		# 		if @result[:result]
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