require File.expand_path('../base_require', __FILE__)

class OaGetBinding < BaseRequire
	include HttpRequestCalm

	def initialize(path, userName, password)
		@url = URI(path)
		@params = {serviceName: 'clogin', userName: "#{userName}", password: "#{password}"}
		@result = {result: false, return_info: '', binding: ''}
	end

	def request
		request = Net::HTTP::Post.new(@url)
		request.set_form_data(@params)
		request["Accept"] = 'application/json'

		# http.request(request) do |res|
		# 	case res
		# 	when Net::HTTPOK
		# 		json_data = JSON.parse(res.body)
		#
		# 		@result[:result] = json_data["result"]
		# 		if @result[:result]
		# 			@result[:binding] = json_data["binding"]
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
					@result[:binding] = json_data["binding"]
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


