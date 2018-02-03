module HttpRequestCalm
	# Must use with block
	# uri = URI.parse 'http://google.com'
	# req = Net::HTTP::Get.new uri.request_uri
	# http_request_calm uri, req do |res|
	#   puts res.body  # res may be nil
	# end

	def http_request_calm(uri, request, options={})
		open_timeout = options[:open_timeout] || 120
		read_timeout = options[:read_timeout] || 120
		ssl_timeout  = options[:ssl_timeout]  || 120
		retry_limit  = options[:retry_limit]  || 10
		wait_seconds = options[:wait_seconds] || 10
		debug_output = options[:debug_output]

		http              = Net::HTTP.new(uri.host, uri.port)
		http.open_timeout = open_timeout
		http.read_timeout = read_timeout

		if uri.scheme == 'https'
			http.use_ssl     = true
			http.ssl_timeout = ssl_timeout
			if Rails.env.development?
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
		end

		http.set_debug_output(debug_output) if debug_output

		begin
			http.request(request) { |res|
				return yield(res)
			}
		rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNRESET, Errno::ETIMEDOUT => e
			if retry_limit > 0
				sleep wait_seconds if wait_seconds > 0
				retry_limit -= 1
				retry
			end
			raise e, e.message, caller
		end
	ensure
		http.finish if !http.nil? && http.started?
	end
end