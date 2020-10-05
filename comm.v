module comm(
    input CLK_50,
//  input RxD,
    output TxD
//	output reg READY_LED = 0,
//	output reg REC_LED = 0,
//	output reg txDrive

//  output reg [7:0] GPout,  // general purpose outputs
//  input [7:0] GPin  // general purpose inputs
);

    wire txDone;
    wire txActive;

    reg txDrive;

    reg [7:0] GPin;

    // For 112500 baud with CLK @ 50MHz
    localparam CLKS_PER_BIT = 444;

    localparam IDLE         = 3'b000;
    localparam START        = 3'b001;
    localparam WAIT_READY   = 3'b010;
    localparam DONE  		= 3'b011;
    localparam WAIT_DONE    = 3'b100;

    localparam LOW          = 1'b0;
    localparam HIGH         = 1'b1;

    reg [2:0] SM = IDLE;

    integer count = 0;

    always @(posedge CLK_50)
    begin

        txDrive <= LOW;

        case (SM)

            IDLE:
                begin
                // Do something interesting here

                // So that this is separated enough
                // to be decoded for a test
                    if (count == 50000)
                    begin
                        count = 0;
                        SM <= WAIT_READY;
                    end

                    count = count + 1;
                end

            START:
                begin
                    txDrive <= HIGH;
                    GPin <= 8'b01000110; // F
                    SM <= WAIT_DONE;
                end

            WAIT_READY:
                begin
                    if (txActive == LOW)
                        SM <= START;
                end

            WAIT_DONE:
                begin
                    if (txDone == HIGH)
                    begin
                        SM <= DONE;
                    end
                end

            DONE:
                SM <= IDLE;

            default:
                SM <= IDLE;

        endcase

    end

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) transmit(.i_Clock(CLK_50),
                .i_TX_DV(txDrive),
                .i_TX_Byte(GPin),
                .i_Rst_L(1), // Has to be high
                .o_TX_Serial(TxD),
                .o_TX_Active(txActive),
                .o_TX_Done(txDone)
                );

endmodule
