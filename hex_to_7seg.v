// Module: hex_to_7seg
// Description: Converts a 4-bit binary input to a 7-segment hexadecimal display pattern.
// Segment Mapping: out_seg = {g, f, e, d, c, b, a}

module hex_to_7seg (
    input  wire [3:0] bin_in,   // 4-bit binary input (0 to 15)
    output reg  [6:0] out_seg   // 7-segment output (Active LOW for Common Anode)
);

    always @(*) begin
        case (bin_in)
            4'h0: out_seg = 7'b1000000; // Displays '0'
            4'h1: out_seg = 7'b1111001; // Displays '1'
            4'h2: out_seg = 7'b0100100; // Displays '2'
            4'h3: out_seg = 7'b0110000; // Displays '3'
            4'h4: out_seg = 7'b0011001; // Displays '4'
            4'h5: out_seg = 7'b0010010; // Displays '5'
            4'h6: out_seg = 7'b0000010; // Displays '6'
            4'h7: out_seg = 7'b1111000; // Displays '7'
            4'h8: out_seg = 7'b0000000; // Displays '8'
            4'h9: out_seg = 7'b0010000; // Displays '9'
            4'hA: out_seg = 7'b0001000; // Displays 'A'
            4'hB: out_seg = 7'b0000011; // Displays 'b' (lowercase to distinguish from '8')
            4'hC: out_seg = 7'b1000110; // Displays 'C'
            4'hD: out_seg = 7'b0100001; // Displays 'd' (lowercase to distinguish from '0')
            4'hE: out_seg = 7'b0000110; // Displays 'E'
            4'hF: out_seg = 7'b0001110; // Displays 'F'
            default: out_seg = 7'b1111111; // Turns all segments OFF
        endcase
    end

endmodule
