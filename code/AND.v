module AND
(
    branch_i,
    equal_i,
    branch_o
);

input   branch_i, equal_i;
output  branch_o;

assign branch_o = branch_i & equal_i;

endmodule
