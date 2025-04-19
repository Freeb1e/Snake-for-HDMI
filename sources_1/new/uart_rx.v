module uart_rx(
	input 			sys_clk,			//50Mϵͳʱ��
	input 			sys_rst_n,			//ϵͳ��λ
	input 			uart_rxd,			//����������
	output reg 		uart_rx_done,		//���ݽ�����ɱ�־
	output reg [7:0]uart_rx_data,	//���յ�������
	//output           led,
	output reg [2:0]direction,
	output reg [1:0]mode,
	output reg rst1,
	output reg pause
);
//�����������ʣ��ɸ���
     parameter	BPS=9600;					//������9600bps���ɸ���
     parameter	SYS_CLK_FRE=50_000_000;		//50Mϵͳʱ��
     localparam	BPS_CNT=SYS_CLK_FRE/BPS;	//����һλ��������Ҫ��ʱ�Ӹ���
     
     parameter UP = 8'd1, LEFT = 8'd2, DOWN = 8'd3, RIGHT = 8'd4;
	 parameter SUP = 3'd1, SLEFT = 3'd2, SDOWN = 3'd3, SRIGHT = 3'd4;
	 parameter PAUSE=8'd6,START=8'd5,AGAIN=8'd11;
	 parameter MODE1=8'd7,MODE2=8'd8,MODE3=8'd9,MODE4=8'd10;
     reg 			uart_rx_d0;		//�Ĵ�1��
     reg 			uart_rx_d1;		//�Ĵ�2��
     reg [15:0]		clk_cnt;				//ʱ�Ӽ�����
     reg [3:0]		rx_cnt;					//���ռ�����
     reg 			rx_flag;				//���ձ�־λ
     reg [7:0]		uart_rx_data_reg;		//���ݼĴ�
     wire 			neg_uart_rx_data;		//���ݵ��½���


//reg led_a=1;
//assign  led=led_a;

assign	neg_uart_rx_data=uart_rx_d1 & (~uart_rx_d0);  //���������ߵ��½��أ�������־���ݴ��俪ʼ
//�������ߴ����ģ�����1��ͬ����ͬʱ�����źţ���ֹ����̬������2�����Բ����½���
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		uart_rx_d0<=1'b0;
		uart_rx_d1<=1'b0;
	end
	else begin
		uart_rx_d0<=uart_rxd;
		uart_rx_d1<=uart_rx_d0;
	end		
end
//���������½��أ���ʼλ0�������ߴ��俪ʼ��־λ�����ڵ�9�����ݣ���ֹλ���Ĵ���������У����ݱȽ��ȶ����ٽ����俪ʼ��־λ���ͣ���־�������
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		rx_flag<=1'b0;
	else begin 
		if(neg_uart_rx_data)
			rx_flag<=1'b1;
		else if((rx_cnt==4'd9)&&(clk_cnt==BPS_CNT/2))//�ڵ�9�����ݣ���ֹλ���Ĵ���������У����ݱȽ��ȶ����ٽ����俪ʼ��־λ���ͣ���־�������
			rx_flag<=1'b0;
		else 
			rx_flag<=rx_flag;			
	end
end
//ʱ��ÿ����һ��BPS_CNT������һλ��������Ҫ��ʱ�Ӹ��������������ݼ�������1��������ʱ�Ӽ�����
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		rx_cnt<=4'd0;
		clk_cnt<=16'd0;
	end
	else if(rx_flag)begin
		if(clk_cnt<BPS_CNT-1'b1)begin
			clk_cnt<=clk_cnt+1'b1;
			rx_cnt<=rx_cnt;
		end
		else begin
			clk_cnt<=16'd0;
			rx_cnt<=rx_cnt+1'b1;
		end
	end
	else begin
		rx_cnt<=4'd0;
		clk_cnt<=16'd0;
	end		
end
//��ÿ�����ݵĴ���������У����ݱȽ��ȶ������������ϵ����ݸ�ֵ�����ݼĴ���
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		uart_rx_data_reg<=8'd0;
	else if(rx_flag)
		if(clk_cnt==BPS_CNT/2) begin
			case(rx_cnt)			
				4'd1:uart_rx_data_reg[0]<=uart_rxd;
				4'd2:uart_rx_data_reg[1]<=uart_rxd;
				4'd3:uart_rx_data_reg[2]<=uart_rxd;
				4'd4:uart_rx_data_reg[3]<=uart_rxd;
				4'd5:uart_rx_data_reg[4]<=uart_rxd;
				4'd6:uart_rx_data_reg[5]<=uart_rxd;
				4'd7:uart_rx_data_reg[6]<=uart_rxd;
				4'd8:uart_rx_data_reg[7]<=uart_rxd;
				default:;
			endcase
		end
		else
			uart_rx_data_reg<=uart_rx_data_reg;
	else
		uart_rx_data_reg<=8'd0;
end	
//�����ݴ��䵽��ֹλʱ�����ߴ�����ɱ�־λ�������������
always@(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		uart_rx_done<=1'b0;
		uart_rx_data<=8'd0;
	end	
	else if(rx_cnt==4'd9)begin
		uart_rx_done<=1'b1;
		uart_rx_data<=uart_rx_data_reg;
	end		
	else begin
		uart_rx_done<=1'b0;
		uart_rx_data<=8'd0;
	end
end


reg [7:0] last_direction;
always@(posedge sys_clk or negedge sys_rst_n)
   begin
if(!sys_rst_n||!rst1)
begin
	direction<=SRIGHT;
	last_direction<=8'd4;
end
else begin	
   if(uart_rx_done&&(!pause))
   begin
            case(uart_rx_data)
				UP:   if(last_direction!=UP && last_direction!=DOWN)
				begin
					last_direction<=uart_rx_data;//�����洢��һ�εķ���
					direction<=SUP;
				end
				LEFT: if(last_direction!=LEFT && last_direction!=RIGHT)
				begin
					last_direction<=uart_rx_data;
					direction<=SLEFT;
				end 
				DOWN: if(last_direction!=UP && last_direction!=DOWN)
				begin
					last_direction<=uart_rx_data;
					direction<=SDOWN;
				end
				RIGHT: if(last_direction!=LEFT && last_direction!=RIGHT)
				begin
					last_direction<=uart_rx_data;
					direction<=SRIGHT;
				end
				default: begin
					last_direction<=last_direction;
					direction<=direction;			
				end
			endcase
			end	
			end
			end
always@(posedge sys_clk or negedge sys_rst_n)
   begin if(!sys_rst_n) begin
	pause<=1'b1;
	rst1<=1'b1;
	mode<=2'd0;
    end		
	else begin	
      if(uart_rx_done)
        begin
            case(uart_rx_data)
            MODE1:begin
					mode<=2'd0;
					rst1<=rst1;
					pause<=pause;
				end
				MODE2:begin
					mode<=2'd1;
					rst1<=rst1;
					pause<=pause;
				end
				MODE3:begin
					mode<=2'd2;
					rst1<=rst1;
					pause<=pause;
				end
				MODE4:begin
					mode<=2'd3;
					rst1<=rst1;
					pause<=pause;
				end				
				PAUSE:begin
					pause<=1'b1;
					rst1<=rst1;
					mode<=mode;
				end
				START:begin
					pause<=1'b0;
					rst1<=1'b1;
					mode<=mode;
				end
			    AGAIN:begin
				     rst1<=0;
				     pause<=1'b1;
				     mode<=mode;		     
				end
				default: begin
					pause<=pause;
					rst1<=rst1;
					mode<=mode;			
				end
            endcase
end
end
   end
endmodule