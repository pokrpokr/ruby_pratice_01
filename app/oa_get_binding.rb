require '/Users/chai/workspace_custom_insert/app/base_require'

class OaGetBinding < BaseRequire
	def initialize(path)
		@url = URI(path)
		@params = {serviceName: 'clogin', userName: 'guoxiaolin@zhubaijia.com', password: '111111'}
		@result = {result: false, return_info: '', binding: ''}
	end

	def request
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


