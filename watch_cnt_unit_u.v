`timescale 1ns / 1ps


module cnt_unit(
    input clk,
    input rst,
    input i_btnR,
    input i_btnL,
    input i_btnD,
    input i_btnU,
    input sw2,
    output reg o_hour_up,
    output reg o_hour_down,
    output reg o_min_up,
    output reg o_min_down,
    output reg o_sec_up,
    output reg o_sec_down
    );

    //state
    parameter [1:0] WATCH = 0, HOUR_SET = 1, MIN_SET = 2, SEC_SET = 3;
    reg [1:0] c_state, n_state;


    //state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin //초기화
            c_state <= WATCH;
        end else begin
            c_state <= n_state;
        end
    end

    // output logic
    always @(posedge clk, posedge rst) begin
        if (rst) begin //초기화
            o_hour_up<=0;
            o_hour_down <= 0;
            o_min_up <= 0;
            o_min_down <= 0;
            o_sec_up <= 0;
            o_sec_down <= 0;
        end else begin
            o_hour_up<=0;
            o_hour_down <= 0;
            o_min_up <= 0;
            o_min_down <= 0;
            o_sec_up <= 0;
            o_sec_down <= 0;
            if(c_state == HOUR_SET && i_btnU) begin
                o_hour_up <= 1;
            end else if (c_state == HOUR_SET && i_btnD) begin
                o_hour_down <= 1;
            end else if(c_state == MIN_SET && i_btnU) begin
                o_min_up <=1;
            end else if(c_state == MIN_SET && i_btnD) begin
                o_min_down <=1;
            end else if(c_state == SEC_SET && i_btnU) begin
                o_sec_up <=1;
            end else if(c_state == SEC_SET && i_btnD) begin
                o_sec_down <=1;
            end
        end
    end

    //next, output CL
    always @(*) begin
        n_state = c_state;
        if(sw2) begin
            case (c_state)
                WATCH : begin
                    if (i_btnR) begin
                        n_state = HOUR_SET;
                    end else if(i_btnL) begin
                        n_state = SEC_SET;
                    end else n_state = c_state;
                end
                HOUR_SET: begin
                    if (i_btnR) begin
                        n_state = MIN_SET;
                    end else if(i_btnL) begin
                        n_state = WATCH;
                    end else n_state = c_state;
                end
                MIN_SET: begin
                    if (i_btnR) begin
                        n_state = SEC_SET;
                    end else if(i_btnL) begin
                        n_state = HOUR_SET;
                    end else n_state = c_state;
                end
                SEC_SET: begin
                    if (i_btnR) begin
                        n_state = WATCH;
                    end else if(i_btnL) begin
                        n_state = MIN_SET;
                    end else n_state = c_state;
                end
            endcase
        end
    end
endmodule
