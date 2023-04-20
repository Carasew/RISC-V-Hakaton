module serdes(
	input clk_rx,
	input clk_tx,
	input rstn,
	input core_en,
	input [8:0] datac_i,
	input [9:0] datap_i,
	output 		serdes_ready,
	output reg		 datac_valid,
	output reg [8:0] datac_o,
	output[9:0] TD
);

parameter K28_7 = 9'h1FC;	//Comma 111 11100 
parameter K28_5 = 9'h1BC;	//Comma 101 11100 = 0FA(00 1111 1010)/305(11 0000 0101)
//parameter K28_5s= 9'h16F;

parameter Wait  = 1;		//Transmittion Off Period
parameter PLen  = 64;	//Tx Max Length

reg [9:0] tx_cnt = 0;
//reg		  tx_state = 0; //1 - Normal, 0 - Sync/Off
reg		  cooled = 0;

reg 	  	  enc_dispin = 0;
//wire [8:0] enc_datain = tx_state | cooled & core_en? (core_en ? datac_i:K28_5):K28_5;
wire [8:0] enc_datain = core_en & cooled ? datac_i:K28_5;

wire [9:0] enc_dataout;
wire [9:0] enc_dataoutINV;
wire [9:0] dec_datain;

wire enc_dispout;
wire enc_illegalk;

reg	[9:0] pout_buf=10'h17C;//01 0111 1100

assign serdes_ready = cooled;
assign TD = pout_buf;

reg [03:0] sum = 0;
reg [01:0] tri_disp = 0; //0,-,+ 
always@(negedge clk_tx) begin
	sum = TD[0]+TD[1]+TD[2]+TD[3]+TD[4]+TD[5]+TD[6]+TD[7]+TD[8]+TD[9];
	if(sum < 5)
		tri_disp <= 1;
	else if(sum > 5)
		tri_disp <= 2;
	else if(!cooled)
		tri_disp <= 1;
		
	case(tri_disp)
		1:	enc_dispin <= 0;
		2:	enc_dispin <= 1;
		default: enc_dispin <= ~enc_dispin;
	endcase
end		
/*	
always@(posedge clk_tx) begin//TX CNT
	if(!rstn) begin
		tx_cnt <= 0;
		tx_state <= 0;
		cooled <= 0;
		pout_buf <= 10'h0FA;
	end else begin
		if (!tx_state) begin
			if (tx_cnt < Wait) begin
				tx_cnt <= tx_cnt + 1;
			end else begin 
				if(core_en) tx_state <= 1;
				cooled <= 1;
				tx_cnt <= 0;
			end
		end else begin
			if (tx_cnt < PLen & core_en)
				tx_cnt <= tx_cnt+1;
			else begin 
				tx_state <= 0;
				tx_cnt <= 0;
				cooled <= 0;
			end
		end
		pout_buf <= enc_illegalk ? 10'h0FA:enc_dataoutINV;
	end
end
*/
always@(posedge clk_tx) begin
	if(!rstn) begin
		tx_cnt <= 0;
		cooled <= 0;
		pout_buf <= 10'h17C;
	end else begin
		if(!cooled | !core_en) begin
			if (tx_cnt < Wait) begin
				tx_cnt <= tx_cnt + 1;
			end else begin 
				cooled <= 1;
				tx_cnt <= 0;
			end
		end else begin
			if( tx_cnt < PLen )
				tx_cnt <= tx_cnt + 1;
			else begin
				tx_cnt <= 0;
				cooled <= 0;
			end
		end
		pout_buf <= enc_illegalk ? 10'h17C:enc_dataout;
	end
end
	
wire [8:0] dec_dataout; 
reg		  dec_dispin = 0;

wire dec_dispout;
wire dec_code_err;
wire dec_disp_err;

always@(posedge clk_rx) begin//RX
	if(!rstn) begin
		dec_dispin <= 0;
		datac_valid <= 0;
		datac_o <= 0;
	end else begin
		dec_dispin <= !dec_code_err ? !dec_dispout: dec_dispout;
		datac_valid <= !dec_code_err & !(dec_dataout == K28_5);
		datac_o <= dec_dataout;
	end
end
/*
assign enc_dataoutINV[0] = enc_dataout[9];
assign enc_dataoutINV[1] = enc_dataout[8];
assign enc_dataoutINV[2] = enc_dataout[7];
assign enc_dataoutINV[3] = enc_dataout[6];
assign enc_dataoutINV[4] = enc_dataout[5];
assign enc_dataoutINV[5] = enc_dataout[4];
assign enc_dataoutINV[6] = enc_dataout[3];
assign enc_dataoutINV[7] = enc_dataout[2];
assign enc_dataoutINV[8] = enc_dataout[1];
assign enc_dataoutINV[9] = enc_dataout[0];

assign dec_datain[0] = datap_i[9];
assign dec_datain[1] = datap_i[8];
assign dec_datain[2] = datap_i[7];
assign dec_datain[3] = datap_i[6];
assign dec_datain[4] = datap_i[5];
assign dec_datain[5] = datap_i[4];
assign dec_datain[6] = datap_i[3];
assign dec_datain[7] = datap_i[2];
assign dec_datain[8] = datap_i[1];
assign dec_datain[9] = datap_i[0];
*/
encode enc(enc_datain, enc_dispin, enc_dataout, enc_dispout,enc_illegalk);

decode dec(datap_i, dec_dispin, dec_dataout, dec_dispout, dec_code_err, dec_disp_err);
endmodule
