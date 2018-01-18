class ShuffleGenerated
	def generate(apiname=nil, type, data)
	# 	apiname['FY', 'JP', 'JD', 'DX', 'XCD', 'FKGD', 'SKGD']
	# 	type['order_num', 'time']
	# 	data{origin_data: '', generate_data: '', create_date: ''}
		case type
		when :time
			result = time_generate(data[:origin_data])

			data[:generate_data] = result
		when :order_num
			if data[:origin_data]
				data[:origin_data] = data[:origin_data]["name"]
			end

			result = reg_num(data[:origin_data], data[:create_date], apiname)

			data[:generate_data] = result
		end
	end
	
	private

	# 时间
	def time_generate(date)
		hour_a = ('07'..'21').to_a
		ms_a = ('00'..'59').to_a

		generate_time = "#{date} #{hour_a.shuffle[0]}:#{ms_a.shuffle[0]}:#{ms_a.shuffle[0]}"

		generate_time
	end

	def reg_num(num=nil, date, type)
		if num
			sub_s = num.match(/\A\S{2,4}(-)\d{8}/)[0]
			suc_n = num.sub(sub_s, '')
		else
			suc_n = '000'
		end
		f_date = ''
		date.split('-').each_with_index do |s, index|
			unless index == 0
				if s.match(/\A\d{1}\z/)
					s = '0' + s
				end
			end
			f_date += s
		end

		# shuffle_s = ''
		# suc_n.length.times do
		# 	shuffle_s += ('0'..'9').to_a.shuffle[0]
		# end

		generate_num = "#{type}-" + f_date + suc_n.succ

		generate_num
	end
end