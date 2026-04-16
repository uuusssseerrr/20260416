`timescale 1ns / 1ps

module stopwatch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input i_runstop,
    input i_clear,
    input i_mode,
    output [MSEC_WIDTH - 1:0] msec,
    output [SEC_WIDTH - 1:0] sec,
    output [MIN_WIDTH - 1:0] min,
    output [HOUR_WIDTH - 1:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    // instance

    //hour
    tick_counter #(
        .TIMES(24),  //이름으로 parameter 연결
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick),  // from sec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(hour),
        .o_tick()
    );

    //min
    tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick),  // from sec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(min),
        .o_tick(w_hour_tick)  // to hour tick counter
    );

    //sec
    tick_counter #(
        .TIMES(60),  //이름으로 parameter 연결
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick),  // from msec o_tick
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(sec),
        .o_tick(w_min_tick)
    );

    //msec
    tick_counter #(
        .TIMES(100),  //이름으로 parameter 연결
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .i_clear(i_clear),
        .i_mode(i_mode),
        .time_counter(msec),
        .o_tick(w_sec_tick)
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .i_clear(i_clear),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule

module tick_counter #(
    parameter TIMES = 100,  // 가장 큰 수
    BIT_WIDTH = 7
) (
    input clk,
    input rst,
    input i_tick,
    input i_clear,
    input i_mode,
    output [BIT_WIDTH - 1 : 0] time_counter,
    output reg o_tick  //지금 CL로 한거임
);

    // counter register
    reg [BIT_WIDTH-1:0] counter_reg, counter_next;
    assign time_counter = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;  // nonblocking
        end
    end

    //next counter CL : blocking =
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (i_tick) begin
            if (i_mode) begin
                counter_next = counter_reg - 1; //input : current / 자기 출력을 받으면 delay 생김. 조합논리는 
                if (counter_reg == 0) begin //여기서 counter_next쓰면 한 클럭 손해봄. 항상 같은 스타일로 짜라 -> reg에서는 시간만. next에서는 연산만.
                    counter_next = TIMES-1;
                    o_tick = 1;
                end else begin
                    o_tick = 1'b0; // 이건 안해도 됨.
                end
            end else begin
                counter_next = counter_reg + 1;
                if(counter_reg == TIMES - 1) begin
                    o_tick = 1;
                    counter_next = 0;
                end else begin
                    o_tick=0;
                end
            end
        end else if (i_clear) begin
            counter_next = 0;
            o_tick = 1'b0;
        end
    end

endmodule

//tick gen 100hz
module tick_gen_100hz (
    input clk,
    input rst,
    input i_runstop,
    input i_clear,
    output reg o_tick_100hz
);

    // 100hz counter number * 1000 for simulation, 10s
    parameter F_COUNT = 100_000_000 / 100_000; //원래 나누기 100
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin //rst에다 i_runstop 넣으면 버그 생김.
            counter_reg  <= 0;
            o_tick_100hz <= 0;
        end else begin
            if(i_runstop) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == F_COUNT - 1) begin
                    counter_reg  <= 0;
                    o_tick_100hz <= 1;
                end else begin
                    o_tick_100hz <= 0;
                end
            end else if (i_clear) begin
                counter_reg <= 0;
                o_tick_100hz <= 1'b0; //확실하게
            end
        end
    end


endmodule
