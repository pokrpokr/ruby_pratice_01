require File.expand_path('../main_require', __FILE__)
require File.expand_path('../../config/config', __FILE__)

class Main < MainRequire
	def initialize(conditions={})
		# app_type: {test, formal}
		case conditions[:app_type]
		when :test
			conditions[:userName] = Config::TEST_USERNAME
			conditions[:password] = Config::TEST_PASSWORD
			conditions[:api_url] = Config::TEST_API_URL
			conditions[:file_path] = Config::TEST_OFFER_FILE_PATH
		when :formal
			conditions[:userName] = Config::FORMAL_USERNAME
			conditions[:password] = Config::FORMAL_PASSWORD
			conditions[:api_url] = Config::FORMAL_API_URL
			conditions[:file_path] = Config::DEC_FILE_PATH
		end
		api_url        = conditions[:api_url]
		file_path      = conditions[:file_path]
		userName       = conditions[:userName]
		password       = conditions[:password]
		oa_get_binding = OaGetBinding.new(api_url, userName, password)
		@result        = oa_get_binding.request
		@file_data     = ReadData.new(file_path, conditions[:app_type])
		@insert        = InsertData.new(api_url)
		@update        = UpdateData.new(api_url)
		@query         = QueryData.new(api_url)
		@generate      = ShuffleGenerated.new
		@type          = conditions[:app_type]
	end

	def run
		if @result[:result]
			@run_result = {success: [], fail: []}
			# 收付款关联订单map
			gl_map = {FY: :glfydd, JP: :gljpdd, JD: :gljddd, DX: :gldxdd}
			binding     = @result[:binding]

			# 行程单单号Hash
			xcd_ids  = {}

			xcd_sxfw = {}

			insert_datas = @file_data.read_data

			# 遍历插入更新数据
			insert_datas.each_with_index do |insert_data, index|
				success_info = {dd: false, fk: false, sk: false}
				info_format  = {data: insert_data, num: index}

				sql          = "select id from Lead where xm = '#{insert_data[:dd][:khxm]}' and is_deleted = 0"
				kh_result    = @query.query_data('Lead', binding, sql)

				puts "+++++++++++++++++++++++++++++++++++++++++++++++++++"
				puts insert_data[:dd][:khxm]
				puts kh_result
				puts "+++++++++++++++++++++++++++++++++++++++++++++++++++"

				unless kh_result[:data]
					@run_result[:fail].push(info_format) and next
				end

				insert_data[:dd][:khxm] = kh_result[:data]["id"]

				# 下单时间
				xdsj = insert_data[:dd][:xdsj]
				shuffle_create_time = @generate.generate(:time, {origin_data: xdsj})

				# 行程单数据结构
				xcd_datas = [{
					mdd:  insert_data[:dd].delete(:mdd),
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

					up_sql        = "update xcd set sxfw='#{xcd_datas[0][:sxfw]}' where id ='#{xcd_ids[insert_data[:same_item]]}'"
					xcd_up_result = @query.query_data('xcd', binding, up_sql)
					puts "***********XCD#{insert_data[:same_item]}************"
					puts "xcd_up_result is #{xcd_up_result}"
					puts "***********XCD#{insert_data[:same_item]}************"

					unless xcd_up_result[:result]
						@run_result[:fail].push(info_format) and next
					end
				else
					xcd_datas[0][:khxm]       = insert_data[:dd][:khxm]

					if @type == :test
						xcd_datas[0][:recordtype] = Config::TEST_XCD_RECORDTYPE
					elsif @type == :formal
						xcd_datas[0][:recordtype] = Config::FORMAL_XCD_RECORDTYPE
					end
					xcd_datas[0][:sfcwdd]     = 'true'
					xcd_datas[0][:sxfw]       = insert_data[:dd][:fwlx]

					xcd_result = dd_insert(:XCD, binding, xcd_datas, insert_data[:same_item])
					if xcd_result[:result]
						xcd_ids["#{insert_data[:same_item]}"] = xcd_result[:oa_id]

						xcd_up_result = dd_update(:XCD, binding, xcd_result[:oa_id], xdsj, insert_data[:same_item], shuffle_create_time)

						unless xcd_up_result[:result]
							@run_result[:fail].push(info_format) and next
						end
					end
				end

				dd_datas            = [insert_data[:dd]]
				dd_datas[0][:glxcd] = xcd_ids[insert_data[:same_item]]
				puts '#############========#############'
				puts dd_datas[0][:glxcd]
				puts '#############========#############'

				case insert_data[:type]
				when :FY
					dd_datas[0][:ddbh] = generate_zbj_no(xdsj)
				when :JP
				when :JD
				when :DX
					dd_datas[0][:fwqdly] = '公司'
				end

				dd_result = dd_insert(insert_data[:type], binding, dd_datas, index)
				if dd_result[:result]
					success_info[:dd]   = true
					dd_id               = dd_result[:oa_id]
					dd_up_result = dd_update(insert_data[:type], binding, dd_id, xdsj, index, shuffle_create_time)
					success_info[:dd] = false unless dd_up_result[:result]

					insert_data[:fk]["#{gl_map[insert_data[:type]]}"] = dd_id
					insert_data[:sk]["#{gl_map[insert_data[:type]]}"] = dd_id
				end

				if success_info[:dd]
					# 付款工单部分
					fk_datas  = [insert_data[:fk]]
					fk_result = fk_insert(fk_datas, binding, index)

					if fk_result[:result]
						success_info[:fk] = true
						fk_id             = fk_result[:oa_id]
						fk_up_result      = fk_update(fk_id, binding, xdsj, index, shuffle_create_time)
						success_info[:fk] = false unless fk_up_result[:result]
					end

					# 收款工单部分
					sk_datas                  = [insert_data[:sk]]
					sk_result = sk_insert(sk_datas, binding, index)

					if sk_result[:result]
						success_info[:sk] = true
						sk_id             = sk_result[:oa_id]
						sk_up_result      = sk_update(sk_id, binding, xdsj, index, shuffle_create_time)
						success_info[:sk] = false unless sk_up_result[:result]
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
		ms_a   = ('00'..'60').to_a

		generate_time = "#{hour_a.shuffle[0]}#{ms_a.shuffle[0]}#{ms_a.shuffle[0]}"
		[
			format_date(date),
			Random.new.rand(10000..99999),
			generate_time
		].join('')
	end

	# =================================================重构代码=====================================================

	def sk_insert(*args)
		sk_datas, binding, index = args
		sk_result         = @insert.insert_data('skgd', binding, sk_datas)
		puts "***********SK-#{index}************"
		puts "sk_result is #{sk_result}"
		puts "***********SK-#{index}************"

		sk_result
	end

	def sk_update(*args)
		sk_id, binding, xdsj, index, shuffle_create_time = args
		sql                = "select name from skgd where id= '#{sk_id}'"
		l_sk_bill_no       = @query.query_data('skgd', binding, sql)
		d_sk_bill          = {origin_data: l_sk_bill_no[:data]["name"], create_date: xdsj}
		shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

		up_sql       = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
		# 更新数据
		sk_up_result = @query.query_data('skgd', binding, up_sql)
		puts "sk_up_result#{index} is #{sk_up_result}"

		sk_up_result
	end

	def fk_insert(*args)
		fk_datas, binding, index = args
		fk_result                 = @insert.insert_data('fkgd', binding, fk_datas)
		puts "***********FK-#{index}************"
		puts "fk_result is #{fk_result}"
		puts "***********FK-#{index}************"

		fk_result
	end

	def fk_update(*args)
		fk_id, binding, xdsj, index, shuffle_create_time = args
		sql                  = "select name from fkgd where id= '#{fk_id}'"
		l_fk_bill_no         = @query.query_data('fkgd', binding, sql)
		d_fk_bill            = {origin_data: l_fk_bill_no[:data]["name"], create_date: xdsj}
		shuffle_fk_bill_no   = @generate.generate(:FKGD, :order_num, d_fk_bill)

		up_sql       = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
		# 更新数据
		fk_up_result = @query.query_data('fkgd', binding, up_sql)
		puts "fk_up_result#{index} is #{fk_up_result}"
		fk_up_result
	end

	def dd_insert(*args)
		type, binding, dd_datas, index = args
		type_map  = {FY: 'fydd',JP: 'jpdd', JD: 'jddd', DX: 'dxfwdd', XCD: 'xcd'}
		dd_result = @insert.insert_data("#{type_map[type]}", binding, dd_datas)
		if type == :XCD
			puts "***********XCD-#{index}************"
			puts "xcd_result is #{dd_result}"
			puts "***********DD-#{index}************"
		else
			puts "***********DD-#{index}************"
			puts "dd_result is #{dd_result}"
			puts "***********DD-#{index}************"
		end

		dd_result
	end

	def dd_update(*args)
		type, binding, dd_id, xdsj, index, shuffle_create_time = args
		type_map = {FY: 'fydd',JP: 'jpdd', JD: 'jddd', DX: 'dxfwdd', XCD: 'xcd'}
		# 搜索相关日期的最后一个订单号
		sql                 = "select name from #{type_map[type]} where id= '#{dd_id}'"
		l_bill_no           = @query.query_data("#{type_map[type]}", binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data]["name"], create_date: xdsj}
		shuffle_bill_no     = @generate.generate(type, :order_num, d_bill)
		# d_time              = {origin_data: xdsj}
		# shuffle_create_time = @generate.generate(:time, d_time)
		if type == :XCD
			up_sql              = "update #{type_map[type]} set name='#{shuffle_bill_no}', createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id='#{dd_id}'"
		else
			up_sql              = "update #{type_map[type]} set name='#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id='#{dd_id}'"
		end
		# 更新数据
		dd_up_result        = @query.query_data("#{type_map[type]}", binding, up_sql)
		if type == :XCD
			puts "xcd_up_result#{index} is #{dd_up_result}"
		else
			puts "dd_up_result#{index} is #{dd_up_result}"
		end

		dd_up_result
	end
end


