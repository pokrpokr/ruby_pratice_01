require File.expand_path('../main_require', __FILE__)

class Main < MainRequire
	def initialize(conditions={})
		api_url = conditions[:api_url] || "http://47.90.54.160/distributor.action"
		file_path = conditions[:file_path] || "/Users/chai/workspace_custom_insert/data_file/后台相关数据.csv"
		oa_get_binding = OaGetBinding.new(api_url)
		@result = oa_get_binding.request
		@file_data = ReadData.new(file_path)
		@insert = InsertData.new(api_url)
		@update = UpdateData.new(api_url)
		@query = QueryData.new(api_url)
		@generate = ShuffleGenerated.new
	end

	def run
		if @result[:result]
			@run_result = {success: [], fail: []}
			binding = @result[:binding]

			# 行程单单号Hash
			xcd_ids = {}

			xcd_sxfw = {}

			insert_datas = @file_data.read_data

			# 遍历插入更新数据
			insert_datas.each_with_index do |insert_data, index|
				success_info = {dd: false, fk: false, sk: false}
				info_format = {data: insert_data, num: index}

				sql = "select id from Lead where name = '#{insert_data[:dd][:khxm]}' and is_deleted = 0"
				kh_result = @query.query_data('Lead', binding, sql)

				unless kh_result[:data]
					@run_result[:fail].push(info_format) and next
				end

				insert_data[:dd][:khxm] = kh_result[:data]["id"]

				xcd_datas = [{
					mdd: insert_data[:dd].delete(:mdd),
					cfrq: insert_data[:dd].delete(:cfrq),
					jsrq: insert_data[:dd].delete(:jsrq),
					rhts: insert_data[:dd].delete(:rhts)
				}]

				if xcd_ids[insert_data[:same_item]]
					# 行程单所需服务数据结构
					if xcd_sxfw["#{xcd_ids[insert_data[:same_item]]}"]
						xcd_sxfw["#{xcd_ids[insert_data[:same_item]]}"] += ";#{insert_data[:dd][:fwlx]}"
					else
						xcd_sxfw["#{xcd_ids[insert_data[:same_item]]}"] = "#{insert_data[:dd][:fwlx]}"
					end

					xcd_datas[0][:sxfw] = xcd_sxfw["#{xcd_ids[insert_data[:same_item]]}"]

					up_sql = "update xcd set sxfw='#{xcd_datas[0][:sxfw]}' where id ='#{xcd_ids[insert_data[:same_item]]}'"
					xcd_up_result = @query.query_data('xcd', binding, up_sql)
					puts "***********XCD#{insert_data[:same_item]}************"
					puts "xcd_up_result is #{xcd_up_result}"
					puts "***********XCD#{insert_data[:same_item]}************"

					unless xcd_up_result[:result]
						@run_result[:fail].push(info_format) and next
					end
				else
					xcd_datas[0][:khxm] = insert_data[:dd][:khxm]
					xcd_datas[0][:recordtype] = '201853C8A8C785FKjZfx'
					xcd_datas[0][:sfcwdd] = 'true'
					xcd_datas[0][:sxfw] = insert_data[:dd][:fwlx]

					xcd_result = @insert.insert_data('xcd', binding, xcd_datas)
					puts "***********XCD#{insert_data[:same_item]}************"
					puts "xcd_result is #{xcd_result}"
					puts "***********XCD#{insert_data[:same_item]}************"
					if xcd_result[:result]
						xcd_ids["#{insert_data[:same_item]}"] = xcd_result[:oa_id]

						sql = "select name from xcd where id = '#{xcd_result[:oa_id]}'"
						l_bill_no = @query.query_data('xcd', binding, sql)
						# 更新订单号，创建时间
						d_bill = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
						shuffle_bill_no = @generate.generate(:XCD, :order_num, d_bill)
						d_time = {origin_data: insert_data[:dd][:xdsj]}
						shuffle_create_time = @generate.generate(:time, d_time)
						up_sql = "update xcd set name='#{shuffle_bill_no}', createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{xcd_result[:oa_id]}'"
						# 更新数据
						xcd_up_result =  @query.query_data('xcd', binding, up_sql)
						puts "********************Update**********************"
						puts "xcd_up_result is #{xcd_up_result}"
						puts "********************Update**********************"

						unless xcd_up_result[:result]
							@run_result[:fail].push(info_format) and next
						end
					end
				end

				dd_datas = [insert_data[:dd]]
				dd_datas[0][:glxcd] = xcd_ids[insert_data[:same_item]]
				puts '#############========#############'
				puts dd_datas[0][:glxcd]
				puts '#############========#############'

				case insert_data[:type]
				when :FY
					dd_datas[0][:ddbh] = generate_zbj_no(insert_data[:dd][:xdsj])
					fy_result = @insert.insert_data('fydd', binding, dd_datas)
					puts "***********FY#{index}************"
					puts "fy_result is #{fy_result}"
					puts "***********FY#{index}************"
					if fy_result[:result]
						success_info[:dd] = true
						fy_id = fy_result[:oa_id]
						# 搜索相关日期的最后一个订单号
						sql = "select name from fydd where name like '#{format_date(insert_data[:dd][:xdsj])}%'"
						l_bill_no = @query.query_data('fydd', binding, sql)
						# 更新订单号，创建时间
						d_bill = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
						shuffle_bill_no = @generate.generate(:FY, :order_num, d_bill)
						d_time = {origin_data: insert_data[:dd][:xdsj]}
						shuffle_create_time = @generate.generate(:time, d_time)
						up_sql = "update fydd set name = '#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fy_id}'"
						# 更新数据
						fy_up_result =  @query.query_data('fydd', binding, up_sql)
						puts "fy_up_result#{index} is #{fy_up_result}"
						success_info[:dd] = false unless fy_up_result[:result]

						insert_data[:fk][:glfydd] = fy_id
						fk_datas = [insert_data[:fk]]
						fk_result = @insert.insert_data('fkgd', binding, fk_datas)
						puts "**********FK#{index}*************"
						puts "fk_result is #{fk_result}"
						puts "**********FK#{index}*************"
						if fk_result[:result]
							success_info[:fk] = true
							fk_id = fk_result[:oa_id]
							sql = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_fk_bill_no = @query.query_data('fkgd', binding, sql)
							d_fk_bill = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

							up_sql = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
							# 更新数据
							fk_up_result =  @query.query_data('fkgd', binding, up_sql)
							puts "fk_up_result#{index} is #{fk_up_result}"
							success_info[:fk] = false unless fk_up_result[:result]
						end

						insert_data[:sk][:glfydd] = fy_id
						sk_datas = [insert_data[:sk]]
						sk_result = @insert.insert_data('skgd', binding, sk_datas)
						puts "***********SK#{index}************"
						puts "sk_result is #{sk_result}"
						puts "***********SK#{index}************"
						if sk_result[:result]
							success_info[:sk] = true

							sk_id = sk_result[:oa_id]
							sql = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_sk_bill_no = @query.query_data('skgd', binding, sql)
							d_sk_bill = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

							up_sql = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
							# 更新数据
							sk_up_result =  @query.query_data('skgd', binding, up_sql)
							puts "sk_up_result#{index} is #{sk_up_result}"
							success_info[:sk] = false unless sk_up_result[:result]
						end
					end
				when :JP
					jp_result = @insert.insert_data('jpdd', binding, dd_datas)
					puts "***********JP#{index}************"
					puts "jp_result is #{jp_result}"
					puts "***********JP#{index}************"
					if jp_result[:result]
						success_info[:dd] = true
						jp_id = jp_result[:oa_id]
						# 搜索相关日期的最后一个订单号
						sql = "select name from jddd where name like '#{format_date(insert_data[:dd][:xdsj])}%'"
						l_bill_no = @query.query_data('jddd', binding, sql)
						# 更新订单号，创建时间
						d_bill = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
						shuffle_bill_no = @generate.generate(:JP, :order_num, d_bill)
						d_time = {origin_data: insert_data[:dd][:xdsj]}
						shuffle_create_time = @generate.generate(:time, d_time)
						up_sql = "update jpdd set name = '#{shuffle_bill_no}', xdsj = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{jp_id}'"
						# 更新数据
						jp_up_result =  @query.query_data('jpdd', binding, up_sql)
						puts "jp_up_result#{index} is #{jp_up_result}"
						success_info[:dd] = false unless jp_up_result[:result]

						insert_data[:fk][:gljpdd] = jp_id
						fk_datas = [insert_data[:fk]]
						fk_result = @insert.insert_data('fkgd', binding, fk_datas)
						puts "***********FK#{index}************"
						puts "fk_result is #{fk_result}"
						puts "***********FK#{index}************"
						if fk_result[:result]
							success_info[:fk] = true
							fk_id = fk_result[:oa_id]
							sql = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_fk_bill_no = @query.query_data('fkgd', binding, sql)
							d_fk_bill = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

							up_sql = "update fkgd set name = '#{shuffle_fk_bill_no}', to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
							# 更新数据
							fk_up_result =  @query.query_data('fkgd', binding, up_sql)
							puts "fk_up_result#{index} is #{fk_up_result}"
							success_info[:fk] = false unless fk_up_result[:result]
						end

						insert_data[:sk][:gljpdd] = jp_id
						sk_datas = [insert_data[:sk]]
						sk_result = @insert.insert_data('skgd', binding, sk_datas)
						puts "***********SK#{index}************"
						puts "sk_result is #{sk_result}"
						puts "***********SK#{index}************"
						if sk_result[:result]
							success_info[:sk] = true

							sk_id = sk_result[:oa_id]
							sql = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_sk_bill_no = @query.query_data('skgd', binding, sql)
							d_sk_bill = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

							up_sql = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'),cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
							# 更新数据
							sk_up_result =  @query.query_data('skgd', binding, up_sql)
							puts "sk_up_result#{index} is #{sk_up_result}"
							success_info[:sk] = false unless sk_up_result[:result]
						end
					end
				when :JD
					jd_result = @insert.insert_data('jddd', binding, dd_datas)
					puts "***********JD#{index}************"
					puts "jd_result is #{jd_result}"
					puts "***********JD#{index}************"
					if jd_result[:result]
						success_info[:dd] = true
						jd_id = jd_result[:oa_id]
						# 搜索相关日期的最后一个订单号
						sql = "select name from jddd where name like '#{format_date(insert_data[:dd][:xdsj])}%'"
						l_bill_no = @query.query_data('jddd', binding, sql)
						# 更新订单号，创建时间
						d_bill = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
						shuffle_bill_no = @generate.generate(:JD, :order_num, d_bill)
						d_time = {origin_data: insert_data[:dd][:xdsj]}
						shuffle_create_time = @generate.generate(:time, d_time)
						up_sql = "update jddd set name = '#{shuffle_bill_no}', xdsj = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{jd_id}'"
						# 更新数据
						jd_up_result =  @query.query_data('jddd', binding, up_sql)
						puts "jd_up_result#{index} is #{jd_up_result}"
						success_info[:dd] = false unless jd_up_result[:result]

						insert_data[:fk][:gljddd] = jd_id
						fk_datas = [insert_data[:fk]]
						fk_result = @insert.insert_data('fkgd', binding, fk_datas)
						puts "***********FK#{index}************"
						puts "fk_result is #{fk_result}"
						puts "***********FK#{index}************"
						if fk_result[:result]
							success_info[:fk] = true
							fk_id = fk_result[:oa_id]
							sql = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_fk_bill_no = @query.query_data('fkgd', binding, sql)
							d_fk_bill = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

							up_sql = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
							# 更新数据
							fk_up_result =  @query.query_data('fkgd', binding, up_sql)
							puts "fk_up_result#{index} is #{fk_up_result}"
							success_info[:fk] = false unless fk_up_result[:result]
						end

						insert_data[:sk][:gljddd] = jd_id
						sk_datas = [insert_data[:sk]]
						sk_result = @insert.insert_data('skgd', binding, sk_datas)
						puts "***********SK#{index}************"
						puts "sk_result is #{sk_result}"
						puts "***********SK#{index}************"
						if sk_result[:result]
							success_info[:sk] = true

							sk_id = sk_result[:oa_id]
							sql = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_sk_bill_no = @query.query_data('skgd', binding, sql)
							d_sk_bill = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

							up_sql = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
							# 更新数据
							sk_up_result =  @query.query_data('skgd', binding, up_sql)
							puts "sk_up_result#{index} is #{sk_up_result}"
							success_info[:sk] = false unless sk_up_result[:result]
						end
					end
				when :DX
					dd_datas[0][:fwqdly] = '公司'
					dx_result = @insert.insert_data('dxfwdd', binding, dd_datas)
					puts "***********DX#{index}************"
					puts "dx_result is #{dx_result}"
					puts "***********DX#{index}************"
					if dx_result[:result]
						success_info[:dd] = true
						dx_id = dx_result[:oa_id]
						# 搜索相关日期的最后一个订单号
						sql = "select name from dxfwdd where name like '#{format_date(insert_data[:dd][:xdsj])}%'"
						l_bill_no = @query.query_data('dxfwdd', binding, sql)
						# 更新订单号，创建时间
						d_bill = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
						shuffle_bill_no = @generate.generate(:DX, :order_num, d_bill)
						d_time = {origin_data: insert_data[:dd][:xdsj]}
						shuffle_create_time = @generate.generate(:time, d_time)
						up_sql = "update dxfwdd set name='#{shuffle_bill_no}', xdsj = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id='#{dx_id}'"
						# 更新数据
						dx_up_result =  @query.query_data('dxfwdd', binding, up_sql)
						puts "dx_up_result#{index} is #{dx_up_result}"
						success_info[:dd] = false unless dx_up_result[:result]

						insert_data[:fk][:gldxdd] = dx_id
						fk_datas = [insert_data[:fk]]
						fk_result = @insert.insert_data('fkgd', binding, fk_datas)
						puts "***********FK#{index}************"
						puts "fk_result is #{fk_result}"
						puts "***********FK#{index}************"
						if fk_result[:result]
							success_info[:fk] = true
							fk_id = fk_result[:oa_id]
							sql = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_fk_bill_no = @query.query_data('fkgd', binding, sql)
							d_fk_bill = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

							up_sql = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
							# 更新数据
							fk_up_result =  @query.query_data('fkgd', binding, up_sql)
							puts "fk_up_result#{index} is #{fk_up_result}"
							success_info[:fk] = false unless fk_up_result[:result]
						end

						insert_data[:sk][:gldxdd] = dx_id
						sk_datas = [insert_data[:sk]]
						sk_result = @insert.insert_data('skgd', binding, sk_datas)
						puts "***********SK#{index}************"
						puts "sk_result is #{sk_result}"
						puts "***********SK#{index}************"
						if sk_result[:result]
							success_info[:sk] = true

							sk_id = sk_result[:oa_id]
							sql = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
							l_sk_bill_no = @query.query_data('skgd', binding, sql)
							d_sk_bill = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
							shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

							up_sql = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
							# 更新数据
							sk_up_result =  @query.query_data('skgd', binding, up_sql)
							puts "sk_up_result#{index} is #{sk_up_result}"
							success_info[:sk] = false unless sk_up_result[:result]
						end
					end

				end

				puts "=====$$$$$$$$$++++++"
				puts success_info
				puts "=====$$$$$$$$$++++++"

				# 判断是否都成功？
				info = all_success?(success_info)

				if info
					@run_result[:success].push(info_format)
				else
					@run_result[:fail].push(info_format.merge(success_info: success_info))
				end
			end

			@run_result[:success].each do |suc|
				puts "===========成功数据==========="
				puts suc
				puts "===========成功数据==========="
			end
			@run_result[:fail].each do |fal|
				puts "===========失败数据==========="
				puts fal
				puts "===========失败数据==========="
			end

			@run_result
		else
			puts "======================"
			puts "获取binding失败"
			puts "======================"
		end
	end

	private

	def format_date(date)
		f_date = ''

		date.split('-').each_with_index do |d, index|
			unless index == 0
				if d.match(/\A\d{1}\z/)
					d = '0' + d
				end
			end

			f_date += d
		end

		f_date
	end

	def all_success?(success_info)
		result = false
		success_info.values.each do |v|
			result = v.is_a?(TrueClass)
		end

		result
	end

	def generate_zbj_no(date)
		hour_a = ('07'..'21').to_a
		ms_a = ('00'..'60').to_a

		generate_time = "#{hour_a.shuffle[0]}#{ms_a.shuffle[0]}#{ms_a.shuffle[0]}"
		[
			format_date(date),
			Random.new.rand(10000..99999),
			generate_time
		].join('')
	end
end


