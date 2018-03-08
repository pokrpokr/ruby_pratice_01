require 'csv'
require File.expand_path('../../config/config', __FILE__)

class ReadData
	def initialize(csvfile_path, type)
		@csvfile = csvfile_path
		@type = type
	end

	# dd_data = {
	# 	name: "FY-2018121234123",
	# 	ddbh: "111111111111",
	# 	xdsj: "2017-11-20 20:20:20",
	# 	rzrq: "2018-01-01 15:20:30",
	# 	tfrq: "2018-01-03 12:00:00",
	# 	rzrs: "2",
	# 	rzts: "2",
	# 	fybh: "1234",
	# 	cs: "大阪",
	# 	gj: "日本",
	# 	ddzj: "1234.00",
	# 	ddze: "2333.23",
	#   rzrmc: '',
	# 	sfcwdd: 'true',
	#   订单状态
	#   state: ''
	# }
	def read_data
		# 插入数据 -- 数据结构：[{dd: dd_data, fk: fk_data, sk: sk_data, type: type, same_item: same_item},{{dd: dd_data, fk: fk_data, sk: sk_data}},...]
		insert_data = []
		CSV.read(@csvfile, headers: true).each_with_index do |row, index|
			# 插入数据结构
			in_data = {}
			# 订单数据
			dd_data = {}
      # 付款工单数据
			fk_data = {}
			# 收款工单数据
			sk_data = {}
			row = row.to_h
			# 读取对应数据
			case row["订单类型"]
			when "民宿订单"
				type = :FY
				dd_data[:khxm] = row["客户姓名"]
				dd_data[:xdsj] = row["下单时间"]
				dd_data[:state] = row["主状态"] || row["订单状态"]
				dd_data[:rzrq] = row["入住日期"]
				dd_data[:tfrq] = row["退房日期"]
				dd_data[:rzrs] = row["入住人数"]
				dd_data[:rzts] = row["入住天数"]
				dd_data[:fybh] = row["房源ID"]
				dd_data[:cs] = row["城市"]
				dd_data[:gj] = row["国家"]
				# 订单原价
				dd_data[:ddzj] = row["订单原价"]
				# 订单总额
				dd_data[:ddze] = row["订单金额"]
				dd_data[:rzrmc] = row["入住人姓名"]
				dd_data[:fwlx] = '民宿'
				dd_data[:mdd] = "#{row["地区"]}-#{row["国家"]}-#{row["城市"]}"
				dd_data[:cfrq] = row["出发日期"]
				dd_data[:jsrq] = row["结束日期"]
				dd_data[:rhts] = "老板/股东推荐/KA/明星"
				dd_data[:ysglddk] = row["已收关联订单款"] || row["收款金额"]
				dd_data[:yfgysk] = row["已付供应商款"] || row["付款金额"]
				dd_data[:fybh] = row["房源编号"]
				# TODO 财务订单类型ID测试环境
				if @type == :test
					dd_data[:recordtype] = Config::TEST_FY_RECORDTYPE
				elsif @type == :formal
					dd_data[:recordtype] = Config::FORMAL_FY_RECORDTYPE
				end
			when "机票订单"
				type = :JP
				dd_data[:xdsj] = row["下单时间"]
				dd_data[:state] = row["订单状态"]
				dd_data[:khxm] = row["客户姓名"]
				dd_data[:jpzj1] = row["机票总价"]
				dd_data[:ck1] = row["姓名"]
				dd_data[:cklx1] = row["乘客类型"]
				dd_data[:gys1] = row["供应商"]
				dd_data[:cfd1] = row["出发地"]
				dd_data[:mdd1] = row["目的地"]
				dd_data[:ysglddk] = row["已收关联订单款"] || row["收款金额"]
				dd_data[:yfgysk] = row["已付供应商款"] || row["付款金额"]
				dd_data[:fwlx] = '机票'
				dd_data[:mdd] = "#{row["地区"]}-#{row["国家"]}-#{row["城市"]}"
				dd_data[:cfrq] = row["出发日期"]
				dd_data[:jsrq] = row["结束日期"]
				dd_data[:rhts] = "老板/股东推荐/KA/明星"
				# TODO 财务订单类型ID测试环境
				if @type == :test
					dd_data[:recordtype] = Config::TEST_JP_RECORDTYPE
				elsif @type == :formal
					dd_data[:recordtype] = Config::FORMAL_JP_RECORDTYPE
				end
			when "酒店订单"
				type = :JD
				dd_data[:xdsj] = row["下单时间"]
				dd_data[:state] = row["订单状态"]
				dd_data[:khxm] = row["客户姓名"]
				dd_data[:mbcs] = row["目标城市"]
				dd_data[:rzzxm] = row["入住人姓名"]
				dd_data[:rzrq] = row["入住日期"]
				dd_data[:tfrq] = row["退房日期"]
				dd_data[:rzrs] = row["入住人数"]
				dd_data[:rzts] = row["入住天数"]
				dd_data[:fjsl] = row["房间数量"]
				# 订单原价
				dd_data[:ddyj] = row["订单原价"]
				# 订单金额
				dd_data[:ddzj] = row["订单金额"]
				dd_data[:ysglddk] = row["已收关联订单款"] || row["收款金额"]
				dd_data[:yfgysk] = row["已付供应商款"] || row["付款金额"]
				dd_data[:gys] = row["供应商"]
				dd_data[:fx] = row["房型"]
				dd_data[:fwlx] = '酒店'
				dd_data[:mdd] = "#{row["地区"]}-#{row["国家"]}-#{row["城市"]}"
				dd_data[:cfrq] = row["出发日期"]
				dd_data[:jsrq] = row["结束日期"]
				dd_data[:rhts] = "老板/股东推荐/KA/明星"
				# TODO 财务订单类型ID测试环境
				if @type == :test
					dd_data[:recordtype] = Config::TEST_JD_RECORDTYPE
				elsif @type == :formal
					dd_data[:recordtype] = Config::FORMAL_JD_RECORDTYPE
				end
			when "单项订单"
				type = :DX
				dd_data[:xdsj] = row["下单时间"]
				dd_data[:state] = row["订单状态"]
				dd_data[:khxm] = row["客户姓名"]
				dd_data[:mbcs] = row["目标城市"]
				dd_data[:fwlx] = row["服务类型"]
				dd_data[:cfsj] = row["开始时间"]
				dd_data[:ycsj] = row["结束时间"]
				dd_data[:fwnr] = row["服务内容"]
				dd_data[:ddyj] = row["订单原价"]
				dd_data[:ddzj] = row["订单金额"]
				dd_data[:ysglddk] = row["已收关联订单款"] || row["收款金额"]
				dd_data[:yfgysk] = row["已付供应商款"] || row["付款金额"]
				dd_data[:mdd] = "#{row["地区"]}-#{row["国家"]}-#{row["城市"]}"
				dd_data[:cfrq] = row["出发日期"]
				dd_data[:jsrq] = row["结束日期"]
				dd_data[:rhts] = "老板/股东推荐/KA/明星"
				# TODO 财务订单类型ID测试环境
				if @type == :test
					dd_data[:recordtype] = Config::TEST_DX_RECORDTYPE
				elsif @type == :formal
					dd_data[:recordtype] = Config::FORMAL_DX_RECORDTYPE
				end
			end
			# 收款工单
			sk_data[:sklx] = row["收款类型"]
			sk_data[:skfs] = row["收款方式"]
			sk_data[:state] = row["收款工单状态"]
			sk_data[:je] = row["收款金额"]
			sk_data[:hl] = row["收款汇率"]
			sk_data[:skbz] = row["收款币种"]
			sk_data[:rmbje] = row["收款人民币金额"]
			# TODO 财务订单类型ID测试环境
			if @type == :test
				sk_data[:recordtype] = Config::TEST_SK_RECORDTYPE
			elsif @type == :formal
				sk_data[:recordtype] = Config::FORMAL_SK_RECORDTYPE
			end

			# 付款工单
			fk_data[:jslx] = row["结算类型"]
			fk_data[:zdjsrq] = row["指定结算日期"]
			fk_data[:state] = row["付款工单状态"]
			fk_data[:fklx] = row["付款类型"]
			fk_data[:zffs] = row["支付方式"]
			fk_data[:yhmc] = row["银行名称"]
			fk_data[:zhmc] = row["支行名称"]
			fk_data[:skzh] = row["收款账号"] || ""
			fk_data[:je] = row["付款金额"]
			fk_data[:hm] = row["付款户名"]
			fk_data[:bz] = row["付款币种"]
			fk_data[:hl] = row["付款汇率"]
			fk_data[:rmbje] = row["付款人民币金额"]
			# TODO 财务订单类型ID测试环境
			if @type == :test
				fk_data[:recordtype] = Config::TEST_FK_RECORDTYPE
			elsif @type == :formal
				fk_data[:recordtype] = Config::FORMAL_FK_RECORDTYPE
			end

			# 整合数据结构
			in_data[:dd] = dd_data
			in_data[:fk] = fk_data
			in_data[:sk] = sk_data
			in_data[:type] = type
			in_data[:same_item] = row["绑定标识"]

			insert_data.push(in_data)
		end

		insert_data
	end
end