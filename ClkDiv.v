module ClkDiv #( parameter DivRatio_Width = 3)
(
input   wire                            i_ref_clk  ,
input   wire                            i_rst_n    ,
input   wire                            i_clk_en   ,
input   wire    [DivRatio_Width-1:0]    i_div_ratio,
output  reg                             o_div_clk
);

// Input Clock Cycles Counter
reg     [DivRatio_Width-2:0]    counter   ;
reg                             odd_toggle;        

// Even and Odd Flags Control
wire                            odd1_even0  ;
wire    [DivRatio_Width-2:0]    half_ratio  ;
reg                             restart_even;
reg                             restart_odd ;

// Signals to Drive the Output
reg    o_div_clk_r ;
reg    gating_latch; // if the enable didnt toggle at the posedge

// Counter of the Clock Cycles
always@(posedge i_ref_clk or negedge i_rst_n)
  begin
    if(!i_rst_n)
     begin
        counter <= 'b0 ;
        odd_toggle <= 1'b1 ;
     end
    else if(i_clk_en)
     begin
     case(odd1_even0)
     1'b0   : begin
                if(restart_even)
                 begin
                    counter <= 'b0 ;
                 end
                else
                 begin
                    counter <= counter + 1'b1 ;
                 end
            end
     1'b1   : begin
                if(restart_odd)
                 begin
                    counter <= 'b0 ;
                    odd_toggle <= !odd_toggle ;
                 end
                else
                 begin
                    counter <= counter + 1'b1 ;
                 end
            end
     endcase
     end
    else
     begin
        counter <= 'b0 ;
     end
  end
  
/*************************************************************************/
/************************  even and odd flags ****************************/
/*************************************************************************/
// Restart Odd logic
always@(*)
 begin
    if(i_clk_en)
     begin
        restart_odd = (odd1_even0 & restart_even & odd_toggle) | (odd1_even0 & (counter == half_ratio) & !odd_toggle );
     end
    else
     begin
        restart_odd = 1'b0 ;
     end
 end
// Restart Even Logic
always@(*)
 begin
    if(i_clk_en)
     begin
        restart_even = counter == ((i_div_ratio >> 1) - 1'b1);
     end
    else
     begin
        restart_even = 1'b0 ;
     end
 end

assign half_ratio = i_div_ratio >> 1 ;
assign odd1_even0 = i_div_ratio[0] ; // 0 = even , 1 = odd 

/*********************************************************************/
/******************** signals to drive the output ********************/
/*********************************************************************/
// output logic
always@(posedge i_ref_clk or negedge i_rst_n)
  begin
    if(!i_rst_n)
     begin
        o_div_clk_r <= 1'b0 ;
     end
    else if(i_clk_en)
     begin
      case(odd1_even0)
      1'b0   :   o_div_clk_r <= restart_even ? !o_div_clk_r : o_div_clk_r ;
      
      1'b1   :   o_div_clk_r <= restart_odd  ? !o_div_clk_r : o_div_clk_r ;
      endcase
     end
    else
     begin
        o_div_clk_r <= 1'b0 ;
     end
  end
  
// latch for enable (clock gating)
always@(i_ref_clk or i_clk_en)
 begin
    if(!i_ref_clk)
     begin
        gating_latch <= i_clk_en;
     end
 end
 
// Output Combinational logic
always@(*)
 begin
    if(i_div_ratio == 'b1)
     begin
        o_div_clk = i_ref_clk;
     end
    else if(gating_latch | o_div_clk_r)
     begin
        o_div_clk = o_div_clk_r ;
     end
    else
     begin
        o_div_clk = i_ref_clk ;
     end
 end

endmodule