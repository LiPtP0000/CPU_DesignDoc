`timescale 1ns / 1ps

module CU_tb;

    // �ź�����
    reg clk;
    reg [7:0] ir_data;
    reg flag_jump;

    wire [7:0] car_data;
    wire [23:0] control_word;

    wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C20,C21,C22,C23;
    wire [3:0] ctrl_signal;

    // ʵ����������ģ��
    CAR car_inst (
        .clk(clk),
        .control_word(control_word),
        .ir_data(ir_data),
        .flag_jump(flag_jump),
        .car_data(car_data)
    );

    control_mem ctrl_mem_inst (
        .car(car_data),
        .control_word(control_word)
    );

    CBR cbr_inst (
        .ctrl_memory(control_word),
        .C0(C0), .C1(C1), .C2(C2), .C3(C3),
        .C4(C4), .C5(C5), .C6(C6), .C7(C7),
        .C8(C8), .C9(C9), .C10(C10), .C11(C11),
        .C12(C12), .C13(C13), .C14(C14), .C15(C15),
        .C20(C20), .C21(C21), .C22(C22), .C23(C23),
        .ctrl_signal(ctrl_signal)
    );

    // ����ʱ��
    always #5 clk = ~clk;

    initial begin
        // ��ʼ��
        clk = 0;
        flag_jump = 0;
        ir_data = 8'h00; // Ĭ��ֵ

        // �۲� FETCH �׶�
        #10;
        $display("FETCH: car_data=%h control_word=%b", car_data, control_word);

        // ģ��ִ��һ�� ADD ָ��
        ir_data = 8'h03;
        flag_jump = 0;

        #10;
        $display("ADD step1: car_data=%h control_word=%b", car_data, control_word);

        #10;
        $display("ADD step2: car_data=%h control_word=%b", car_data, control_word);

        #10;
        $display("ADD step3: car_data=%h control_word=%b", car_data, control_word);

        // ģ��������ת JMPGEZ��flag_jump = 1����ת��
        ir_data = 8'h06;
        flag_jump = 1;

        #10;
        $display("JMPGEZ (flag_jump=1): car_data=%h control_word=%b", car_data, control_word);

        #10;
        $display("JMPGEZ continue: car_data=%h control_word=%b", car_data, control_word);

        // ģ�� HALT ָ��
        ir_data = 8'h07;
        flag_jump = 0;

        #10;
        $display("HALT step1: car_data=%h control_word=%b", car_data, control_word);

        #10;
        $display("HALT step2: car_data=%h control_word=%b", car_data, control_word);

        #20;
        $finish;
    end

endmodule

