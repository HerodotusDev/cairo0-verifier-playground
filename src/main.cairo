%builtins output pedersen range_check bitwise poseidon

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, KeccakBuiltin, PoseidonBuiltin, HashBuiltin

// from starkware.cairo.common.math import safe_div, safe_mult
from src.cairo_verifier.layouts.all_cairo.cairo_verifier import verify_cairo_proof
from src.cairo_verifier.objects import CairoVerifierOutput
from src.stark_verifier.core.stark import StarkProof

func main{
    output_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    bitwise_ptr: BitwiseBuiltin*,
    poseidon_ptr: PoseidonBuiltin*,
}() {
    alloc_locals;
    local proof: StarkProof*;
    %{
        from src.stark_verifier.air.parser import parse_proof
        ids.proof = segments.gen_arg(parse_proof(
            identifiers=ids._context.identifiers,
            proof_json=program_input["proof"]))
    %}
    let (program_hash, output_hash) = verify_cairo_proof(proof);

    // Write program_hash and output_hash to output.
    assert [cast(output_ptr, CairoVerifierOutput*)] = CairoVerifierOutput(
        program_hash=program_hash, output_hash=output_hash
    );
    let output_ptr = output_ptr + CairoVerifierOutput.SIZE;

    assert 1 = 1;

    return ();
}