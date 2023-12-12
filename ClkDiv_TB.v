`timescale 1ns/1ps


module ClkDiv_TB ();

////////////////////////////////////////////////////////
////////////         TB Parameters         /////////////
////////////////////////////////////////////////////////
parameter   clk_period        = 10 ,
            DivRatio_Width_TB = 3  ;

////////////////////////////////////////////////////////
////////////          TB Signals           /////////////
////////////////////////////////////////////////////////
reg                             CLK_TB      ;
reg                             RST_TB      ;
reg                             Enable_TB   ;
reg    [DivRatio_Width_TB-1:0]  DivRatio_TB ;
wire                            DivCLK_TB   ;

////////////////////////////////////////////////////////
/////////////     DUT Instantiation        /////////////
////////////////////////////////////////////////////////
ClkDiv #( .DivRatio_Width(DivRatio_Width_TB) ) DUT (
.i_ref_clk(CLK_TB)    ,
.i_rst_n(RST_TB)        ,
.i_clk_en(Enable_TB)      ,
.i_div_ratio(DivRatio_TB),
.o_div_clk(DivCLK_TB)       
);

////////////////////////////////////////////////////////
////////////       Clock Generator         /////////////
////////////////////////////////////////////////////////
initial
 begin
  forever #5  CLK_TB = ~CLK_TB ;
 end

////////////////////////////////////////////////////////
////////////            INITIAL             ////////////
////////////////////////////////////////////////////////
initial
 begin
$dumpfile("ClkDiv.vcd");
$dumpvars;
      
// initialization
initialize() ;

// Reset the design
reset();

delay_periods(2);

$display("\n*************************");
$display("****** TEST CASE 1 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 1");
input_en_ratio(1'b1, 'b1);

delay_periods(50);
Enable_TB = 1'b0;
delay_periods(10);

$display("\n*************************");
$display("****** TEST CASE 2 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 2");
input_en_ratio(1'b1, 'b10);

delay_periods(50);
Enable_TB = 1'b0;
delay_periods(10);

$display("\n*************************");
$display("****** TEST CASE 3 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 3");
input_en_ratio(1'b1, 'b11);

delay_periods(50);
Enable_TB = 1'b0;
delay_periods(10);

$display("\n*************************");
$display("****** TEST CASE 4 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 4");
input_en_ratio(1'b1, 'b100);

delay_periods(50);
Enable_TB = 1'b0;
delay_periods(10);

$display("\n*************************");
$display("****** TEST CASE 5 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 5");
input_en_ratio(1'b1, 'b101);

delay_periods(50);
Enable_TB = 1'b0;
delay_periods(10);

$display("\n*************************");
$display("****** TEST CASE 6 ******");
$display("*************************");
$display("Enable ClkDiv with ratio 4 then 2");
input_en_ratio(1'b1, 'b100);

delay_periods(50);

input_en_ratio(1'b1, 'b010);

delay_periods(50);
Enable_TB = 1'b0;

#100
$stop;
 end

////////////////////////////////////////////////////////
/////////////            TASKS             /////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////
task initialize ;
 begin
  CLK_TB      = 1'b1 ; 
  Enable_TB   = 1'b0 ;
  DivRatio_TB = 'b11 ; // 3
 end
endtask

///////////////////////// RESET /////////////////////////
task reset ;
 begin
  RST_TB = 1'b0  ;  // deactivated
  #(12)
  RST_TB = 1'b1  ;  // activated
 end
endtask

/////////////// Delay periods  /////////////////
task delay_periods ;
 input integer num ;
 
 begin
  #(clk_period*num) ;
 end
endtask

/////// Input Enable with ratio  //////////
task input_en_ratio ;
 input                          en  ;
 input [DivRatio_Width_TB-1:0]  ratio ;
 
 begin
    Enable_TB = en ;
    DivRatio_TB = ratio ;
 end
endtask

endmodule