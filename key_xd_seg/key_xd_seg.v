module key_xd_seg(
	clk,
	rst_n,
	seg_sel,
	segment,
	key
);
input clk ;
input rst_n ;
input [2:0]key;
output [7:0] seg_sel ;
output [6:0] segment ;
reg [7:0] seg_sel ;
reg [6:0] segment ;
reg [9:0] cnt0;
reg [2:0] cnt1;
wire [2:0]key_out;
wire add_cnt0;
wire end_cnt0;
wire add_cnt1;
wire end_cnt1;

 key_xd key_xd(
	.clk(clk),
	.rst_n(rst_n),
	.key_in(key),
	.key_vld(key_out)
	);
always @(posedge clk or negedge rst_n)begin//用扫描数码管的俩个计数器
 if(!rst_n)begin
 cnt0 <= 0;
 end
 else if(add_cnt0)begin
 if(end_cnt0)
 cnt0 <= 0;
 else
 cnt0 <= cnt0 + 1;
 end
end
assign add_cnt0 = 1 ;
assign end_cnt0 = add_cnt0 && cnt0==1000-1 ;

always @(posedge clk or negedge rst_n)begin 
 if(!rst_n)begin
 cnt1 <= 0;
 end
 else if(add_cnt1)begin
 if(end_cnt1)
 cnt1 <= 0;
 else
 cnt1 <= cnt1 + 1;
 end
end
assign add_cnt1 = end_cnt0;
assign end_cnt1 = add_cnt1 && cnt1==8-1 ;



always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		seg_sel<=8'b11111111;
	end
	else   begin
		case(cnt1)
		0:seg_sel<=8'b11111110;
		1:seg_sel<=8'b11111101;
		2:seg_sel<=8'b11111011;
		3:seg_sel<=8'b11110111;
		4:seg_sel<=8'b11101111;
		5:seg_sel<=8'b11011111;
		6:seg_sel<=8'b10111111;
		7:seg_sel<=8'b01111111;
		default:seg_sel<=seg_sel;
		endcase
	end
end
reg[3:0] sel_data;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		segment<=7'h01;
	end
	else begin
		case(sel_data)
		0:segment<=7'h01;
        1:segment<=7'h4f;
        2:segment<=7'h12;
        3:segment<=7'h06;
        4:segment<=7'h4c;
        5:segment<=7'h24;
        6:segment<=7'h20;
        7:segment<=7'h0f;
        8:segment<=7'h00;
        9:segment<=7'h04;
        10:segment<=7'h7f;
		default:segment<=segment;
		endcase
	end
end



reg [3:0] sec_seg_1;
reg [2:0] sec_seg_2;

reg [3:0] min_seg_1;
reg [2:0] min_seg_2;

reg [1:0] hou_seg_1;
reg [1:0] hou_seg_2;
reg [25:0]cnt_1s;
reg [25:0]cnt_0_5s;
wire add_cnt_0_5s;
wire end_cnt_0_5s; 
reg  flash_0_5s;
always @(posedge clk or negedge rst_n)begin //用于设置模式时的0.5s的闪烁
 if(!rst_n)begin
 cnt_0_5s <= 0;
 end
 else if(add_cnt_0_5s)begin
 if(end_cnt_0_5s)
 cnt_0_5s <= 0;
 else
 cnt_0_5s <= cnt_0_5s + 1;
 end
end
assign add_cnt_0_5s = key_set1;//进入设置模式就开始计数
assign end_cnt_0_5s = add_cnt_0_5s && cnt_0_5s==2000_0000-1 ;


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		flash_0_5s<=0;
	end
	else if (end_cnt_0_5s) begin
		flash_0_5s<=~flash_0_5s;
	end
end

wire add_cnt_1s;
wire end_cnt_1s; 
always @(posedge clk or negedge rst_n)begin
 if(!rst_n)begin
 cnt_1s <= 0;
 end
 else if(add_cnt_1s)begin
 if(end_cnt_1s)
 cnt_1s <= 0;
 else
 cnt_1s <= cnt_1s + 1;
 end
end
assign add_cnt_1s = key_set1==0;//进入设置模式就停止计数
assign end_cnt_1s = add_cnt_1s && cnt_1s==50_000000-1 ;

//秒
wire add_sec_1;
wire end_sec_1;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sec_seg_1<=0;	
	end
	else if (add_sec_1) begin
		if (end_sec_1) begin
			sec_seg_1<=0;
		end
		else begin
			sec_seg_1<=sec_seg_1+1;
		end
	end
end
assign add_sec_1 = end_cnt_1s||((key_set2==0)&& key_set3 &&key_set1) ;
assign end_sec_1 = add_sec_1&& sec_seg_1 == 10-1 ;

wire add_sec_2;
wire end_sec_2;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sec_seg_2<=0;	
	end
	else if (add_sec_2) begin
		if (end_sec_2) begin
			sec_seg_2<=0;
		end
		else begin
			sec_seg_2<=sec_seg_2+1;
		end
	end
end
assign add_sec_2 = end_sec_1 || ((key_set2==1)&& key_set3&&key_set1);
assign end_sec_2 = add_sec_2&& sec_seg_2 == 6-1 ;
//分钟
wire add_min_1;
wire end_min_1;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		min_seg_1<=0;	
	end
	else if (add_min_1) begin
		if (end_min_1) begin
			min_seg_1<=0;
		end
		else begin
			min_seg_1<=min_seg_1+1;
		end
	end
end
assign add_min_1 = end_sec_2 || ((key_set2==2)&& key_set3&&key_set1);
assign end_min_1 = add_min_1 && min_seg_1 == 10-1 ;

wire add_min_2;
wire end_min_2;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		min_seg_2<=0;	
	end
	else if (add_min_2) begin
		if (end_min_2) begin
			min_seg_2<=0;
		end
		else begin
			min_seg_2<=min_seg_2+1;
		end
	end
end
assign add_min_2 = end_min_1 || ((key_set2==3)&& key_set3&&key_set1);
assign end_min_2 = add_min_2 && min_seg_2 == 6-1 ;

//时
reg [3:0]x;
wire add_hou_1;
wire end_hou_1;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		hou_seg_1<=3;	
	end
	else if (add_hou_1) begin
		if (end_hou_1) begin
			hou_seg_1<=0;
		end
		else begin
			hou_seg_1<=hou_seg_1+1;
		end
	end
end
assign add_hou_1 =  end_min_2 || ((key_set2==4)&& key_set3&&key_set1);
assign end_hou_1 = add_hou_1 && hou_seg_1 == x-1 ;

wire add_hou_2;
wire end_hou_2;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		hou_seg_2<=2;	
	end
	else if (add_hou_2) begin
		if (end_hou_2) begin
			hou_seg_2<=0;
		end
		else begin
			hou_seg_2<=hou_seg_2+1;
		end
	end
end
assign add_hou_2 =  end_hou_1 ||((key_set2==5)&& key_set3&&key_set1);
assign end_hou_2 = add_hou_2 && hou_seg_2 == 3-1 ;



always@(*)begin
	if (hou_seg_2 == 2) begin
		x<=4;
	end
	else begin
		x<=10;
	end
end



// always@(*)begin
// 	case(cnt1)
// 	0:begin
// 	sel_data<=hou_seg_2;
// 	end
// 	1:begin
// 			sel_data<=hou_seg_1;
// 	end
	
// 	2:begin
	
// 			sel_data<=min_seg_2;
// 	end
// 	3:begin 
	
// 			sel_data<=min_seg_1;
// 	end
// 	4:begin

// 			sel_data<=sec_seg_2;   
// 	end
// 	5:
//         sel_data<=sec_seg_1;
  
// 	default:sel_data<=0;
// 	endcase
// end
//////
always@(*)begin
	case(cnt1)
	0:begin
	if (key_set2==5) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=hou_seg_2;
		end
	end
	else begin
			sel_data<=hou_seg_2;
	end
	end
	1:begin
	if (key_set2==4) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=hou_seg_1;
		end
	end
	else begin
			sel_data<=hou_seg_1;
	end
	end
	2:begin
	if (key_set2==3) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=min_seg_2;
		end
	end
	else begin
			sel_data<=min_seg_2;
	end
	end
	3:begin 
	if (key_set2==2) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=min_seg_1;
		end
	end
	else begin
			sel_data<=min_seg_1;
	end    
	end
	4:begin
	if (key_set2==1) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=sec_seg_2;
		end
	end
	else begin
			sel_data<=sec_seg_2;
	end    
	end
	5:
	begin
	if (key_set2==0) begin
		if (flash_0_5s) begin
			sel_data<=10;
		end
		else begin
			sel_data<=sec_seg_1;
		end
	end
	else begin
			sel_data<=sec_seg_1;
	end    
	end
	default:sel_data<=0;
	endcase
end


//按键控制
reg key_set1;//控制进入设置模式，高电平有效
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		key_set1<=0;
	end
	else if (key_out[0]) begin
		key_set1<=~key_set1;
	end
	else begin
		key_set1<=key_set1;
	end
end

reg [2:0]key_set2;//选择设置位
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		key_set2<=0;
	end
	else if (key_set1) begin
		if (key_set2 >6-1) begin
			key_set2<=0;
		end
		else if (key_out[1])begin
			key_set2<=key_set2+1;
		end
		else begin
			key_set2<=key_set2;
		end
	end
end

reg key_set3;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		key_set3<=0;
	end
	else if (key_out[2]) begin
		key_set3<=1;
	end
	else begin
		key_set3<=0;
	end
end


endmodule
