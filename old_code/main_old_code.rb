class OldCodeDefs
	def XCD
		# =================================insert重构前代码============================================
		xcd_result = @insert.insert_data('xcd', binding, xcd_datas)
		puts "***********XCD#{insert_data[:same_item]}************"
		puts "xcd_result is #{xcd_result}"
		puts "***********XCD#{insert_data[:same_item]}************"
		# =================================update重构前代码============================================
		sql                 = "select name from xcd where id = '#{xcd_result[:oa_id]}'"
		l_bill_no           = @query.query_data('xcd', binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data]["name"], create_date: insert_data[:dd][:xdsj]}
		shuffle_bill_no     = @generate.generate(:XCD, :order_num, d_bill)
		d_time              = {origin_data: insert_data[:dd][:xdsj]}
		shuffle_create_time = @generate.generate(:time, d_time)
		up_sql              = "update xcd set name='#{shuffle_bill_no}', createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{xcd_result[:oa_id]}'"
		# 更新数据
		xcd_up_result       = @query.query_data('xcd', binding, up_sql)
		puts "********************Update**********************"
		puts "xcd_up_result is #{xcd_up_result}"
		puts "********************Update**********************"
	end
	
	def FY
		# =================================insert重构前代码============================================
		fy_result          = @insert.insert_data('fydd', binding, dd_datas)
		puts "***********FY#{index}************"
		puts "fy_result is #{fy_result}"
		puts "***********FY#{index}************"
		# =================================update重构前代码============================================
		# 搜索相关日期的最后一个订单号
		sql                 = "select name from fydd where name like 'FY-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_bill_no           = @query.query_data('fydd', binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_bill_no     = @generate.generate(:FY, :order_num, d_bill)
		d_time              = {origin_data: insert_data[:dd][:xdsj]}
		shuffle_create_time = @generate.generate(:time, d_time)
		up_sql              = "update fydd set name = '#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fy_id}'"
		# 更新数据
		fy_up_result        = @query.query_data('fydd', binding, up_sql)
		puts "fy_up_result#{index} is #{fy_up_result}"
		# ===============================fk-insert重构前代码===========================================
		fk_result                 = @insert.insert_data('fkgd', binding, fk_datas)
		puts "**********FK#{index}*************"
		puts "fk_result is #{fk_result}"
		puts "**********FK#{index}*************"
		# ===============================fk-update重构前代码===========================================
		sql                = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_fk_bill_no       = @query.query_data('fkgd', binding, sql)
		d_fk_bill          = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

		up_sql       = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
		# 更新数据
		fk_up_result = @query.query_data('fkgd', binding, up_sql)
		puts "fk_up_result#{index} is #{fk_up_result}"
		# ===============================sk-insert重构前代码===========================================
		sk_result                 = @insert.insert_data('skgd', binding, sk_datas)
		puts "***********SK#{index}************"
		puts "sk_result is #{sk_result}"
		puts "***********SK#{index}************"
		# ===============================sk-update重构前代码===========================================
		sql                = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_sk_bill_no       = @query.query_data('skgd', binding, sql)
		d_sk_bill          = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

		up_sql       = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
		# 更新数据
		sk_up_result = @query.query_data('skgd', binding, up_sql)
		puts "sk_up_result#{index} is #{sk_up_result}"
	end

	def JP
		# =================================insert重构前代码============================================
		jp_result = @insert.insert_data('jpdd', binding, dd_datas)
		puts "***********JP#{index}************"
		puts "jp_result is #{jp_result}"
		puts "***********JP#{index}************"
		# =================================update重构前代码============================================
		# 搜索相关日期的最后一个订单号
		sql                 = "select name from jpdd where name like 'JP-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_bill_no           = @query.query_data('jddd', binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_bill_no     = @generate.generate(:JP, :order_num, d_bill)
		d_time              = {origin_data: insert_data[:dd][:xdsj]}
		shuffle_create_time = @generate.generate(:time, d_time)
		up_sql              = "update jpdd set name= '#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{jp_id}'"
		# 更新数据
		jp_up_result        = @query.query_data('jpdd', binding, up_sql)
		puts "jp_up_result#{index} is #{jp_up_result}"
		# ===============================fk-insert重构前代码===========================================
		fk_result                 = @insert.insert_data('fkgd', binding, fk_datas)
		puts "***********FK#{index}************"
		puts "fk_result is #{fk_result}"
		puts "***********FK#{index}************"
		# ===============================fk-update重构前代码===========================================
		sql                = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_fk_bill_no       = @query.query_data('fkgd', binding, sql)
		d_fk_bill          = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

		up_sql       = "update fkgd set name = '#{shuffle_fk_bill_no}', to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
		# 更新数据
		fk_up_result = @query.query_data('fkgd', binding, up_sql)
		puts "fk_up_result#{index} is #{fk_up_result}"
		# ===============================sk-insert重构前代码===========================================
		sk_result                 = @insert.insert_data('skgd', binding, sk_datas)
		puts "***********SK#{index}************"
		puts "sk_result is #{sk_result}"
		puts "***********SK#{index}************"
		# ===============================sk-update重构前代码===========================================
		sql                = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_sk_bill_no       = @query.query_data('skgd', binding, sql)
		d_sk_bill          = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

		up_sql       = "update skgd set name= '#{shuffle_sk_bill_no}', createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'),cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
		# 更新数据
		sk_up_result = @query.query_data('skgd', binding, up_sql)
		puts "sk_up_result#{index} is #{sk_up_result}"
	end

	def JD
		# =================================insert重构前代码============================================
		jd_result = @insert.insert_data('jddd', binding, dd_datas)
		puts "***********JD#{index}************"
		puts "jd_result is #{jd_result}"
		puts "***********JD#{index}************"
		# =================================update重构前代码============================================
		# 搜索相关日期的最后一个订单号
		sql                 = "select name from jddd where name like 'JD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_bill_no           = @query.query_data('jddd', binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_bill_no     = @generate.generate(:JD, :order_num, d_bill)
		d_time              = {origin_data: insert_data[:dd][:xdsj]}
		shuffle_create_time = @generate.generate(:time, d_time)
		up_sql              = "update jddd set name= '#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{jd_id}'"
		# 更新数据
		jd_up_result        = @query.query_data('jddd', binding, up_sql)
		puts "jd_up_result#{index} is #{jd_up_result}"
		# ===============================fk-insert重构前代码===========================================
		fk_result                 = @insert.insert_data('fkgd', binding, fk_datas)
		puts "***********FK#{index}************"
		puts "fk_result is #{fk_result}"
		puts "***********FK#{index}************"
		# ===============================fk-update重构前代码===========================================
		sql                = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_fk_bill_no       = @query.query_data('fkgd', binding, sql)
		d_fk_bill          = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

		up_sql       = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
		# 更新数据
		fk_up_result = @query.query_data('fkgd', binding, up_sql)
		puts "fk_up_result#{index} is #{fk_up_result}"
		# ===============================sk-insert重构前代码===========================================
		sk_result                 = @insert.insert_data('skgd', binding, sk_datas)
		puts "***********SK#{index}************"
		puts "sk_result is #{sk_result}"
		puts "***********SK#{index}************"
		# ===============================sk-update重构前代码===========================================
		sql                = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_sk_bill_no       = @query.query_data('skgd', binding, sql)
		d_sk_bill          = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

		up_sql       = "update skgd set name= '#{shuffle_sk_bill_no}', createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
		# 更新数据
		sk_up_result = @query.query_data('skgd', binding, up_sql)
		puts "sk_up_result#{index} is #{sk_up_result}"
	end

	def DX
		# =================================insert重构前代码============================================
		dx_result            = @insert.insert_data('dxfwdd', binding, dd_datas)
		puts "***********DX#{index}************"
		puts "dx_result is #{dx_result}"
		puts "***********DX#{index}************"
		# =================================update重构前代码============================================
		# 搜索相关日期的最后一个订单号
		sql                 = "select name from dxfwdd where name like 'DX-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_bill_no           = @query.query_data('dxfwdd', binding, sql)
		# 更新订单号，创建时间
		d_bill              = {origin_data: l_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_bill_no     = @generate.generate(:DX, :order_num, d_bill)
		d_time              = {origin_data: insert_data[:dd][:xdsj]}
		shuffle_create_time = @generate.generate(:time, d_time)
		up_sql              = "update dxfwdd set name='#{shuffle_bill_no}', xdsj= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), createdate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id='#{dx_id}'"
		# 更新数据
		dx_up_result        = @query.query_data('dxfwdd', binding, up_sql)
		puts "dx_up_result#{index} is #{dx_up_result}"
		# ===============================fk-insert重构前代码===========================================
		fk_result                 = @insert.insert_data('fkgd', binding, fk_datas)
		puts "***********FK#{index}************"
		puts "fk_result is #{fk_result}"
		puts "***********FK#{index}************"
		# ===============================fk-update重构前代码===========================================
		sql                = "select name from fkgd where name like 'FKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_fk_bill_no       = @query.query_data('fkgd', binding, sql)
		d_fk_bill          = {origin_data: l_fk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_fk_bill_no = @generate.generate(:FKGD, :order_num, d_fk_bill)

		up_sql       = "update fkgd set name = '#{shuffle_fk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{fk_id}'"
		# 更新数据
		fk_up_result = @query.query_data('fkgd', binding, up_sql)
		puts "fk_up_result#{index} is #{fk_up_result}"
		# ===============================sk-insert重构前代码===========================================
		sk_result                 = @insert.insert_data('skgd', binding, sk_datas)
		puts "***********SK#{index}************"
		puts "sk_result is #{sk_result}"
		puts "***********SK#{index}************"
		# ===============================sk-update重构前代码===========================================
		sql                = "select name from skgd where name like 'SKGD-#{format_date(insert_data[:dd][:xdsj])}%'"
		l_sk_bill_no       = @query.query_data('skgd', binding, sql)
		d_sk_bill          = {origin_data: l_sk_bill_no[:data], create_date: insert_data[:dd][:xdsj]}
		shuffle_sk_bill_no = @generate.generate(:SKGD, :order_num, d_sk_bill)

		up_sql       = "update skgd set name = '#{shuffle_sk_bill_no}', createdate = to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss'), cwLastUpdateDate= to_date('#{shuffle_create_time}', 'yyyy-mm-dd hh24:mi:ss') where id = '#{sk_id}'"
		# 更新数据
		sk_up_result = @query.query_data('skgd', binding, up_sql)
		puts "sk_up_result#{index} is #{sk_up_result}"
	end
end