module AND
(
    branch_i,
    equal_i,
    branch_o
);

input   branch_i, equal_i;
output  branch_o;

reg     branch_o;


initial begin
    branch_o = 1'b0;
end

always@(branch_i, equal_i) begin
    if (branch_i && equal_i) begin
        branch_o = 1'b1;
    end
    else begin
        branch_o = 1'b0;
    end
end

endmodule
