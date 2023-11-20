%builtins output pedersen range_check bitwise poseidon

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, KeccakBuiltin, PoseidonBuiltin
from starkware.cairo.cairo_verifier.layouts.all_cairo.cairo_verifier import verify_cairo_proof


func main{
    output_ptr: felt*,
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    keccak_ptr: KeccakBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}() {

    assert 1 = 1;
    return ();
}