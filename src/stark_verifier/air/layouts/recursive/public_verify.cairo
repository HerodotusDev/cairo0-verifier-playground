from starkware.cairo.common.math import assert_le, assert_nn, assert_nn_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_label_location
from src.stark_verifier.air.layout import AirWithLayout
from src.stark_verifier.air.layouts.recursive.autogenerated import (
    BITWISE__ROW_RATIO,
    CPU_COMPONENT_HEIGHT,
    CPU_COMPONENT_STEP,
    LAYOUT_CODE,
    PEDERSEN_BUILTIN_ROW_RATIO,
    RANGE_CHECK_BUILTIN_ROW_RATIO,
)
from src.stark_verifier.air.public_input import PublicInput, SegmentInfo
from src.stark_verifier.air.public_memory import AddrValue
from src.stark_verifier.core.domains import StarkDomains

const MAX_LOG_N_STEPS = 50;
const MAX_RANGE_CHECK = 2 ** 16 - 1;

namespace segments {
    const PROGRAM = 0;
    const EXECUTION = 1;
    const OUTPUT = 2;
    const PEDERSEN = 3;
    const RANGE_CHECK = 4;
    const BITWISE = 5;
    const N_SEGMENTS = 6;
}

const INITIAL_PC = 1;
const FINAL_PC = INITIAL_PC + 4;

// Returns a zero-terminated list of builtins supported by this layout.
func get_layout_builtins() -> (n_builtins: felt, builtins: felt*) {
    let (builtins_address) = get_label_location(data);
    let n_builtins = 4;
    assert builtins_address[n_builtins] = 0;
    return (n_builtins=n_builtins, builtins=builtins_address);

    data:
    dw 'output';
    dw 'pedersen';
    dw 'range_check';
    dw 'bitwise';
    dw 0;
}

// Verifies that the public input represents a valid Cairo statement: there exists a memory
// assignment and a valid corresponding program trace satisfying the public memory requirements.
//
// This function verifies that:
// * The 16-bit range-checks are properly configured
//   (0 <= range_check_min <= range_check_max < 2^16).
// * The layout is valid.
// * The segments for the builtins do not exceed their maximum length (thus,
//   when these builtins are properly used in the program, they will function correctly).
//
// This function DOES NOT verify anything regarding the public memory. This should be verified
// by the user. In particular, it is not validated that:
// * [initial_fp - 2] = initial_fp, which is required to guarantee the "safe call"
//   feature (that is, all "call" instructions will return, even if the called function is
//   malicious). It guarantees that it's not possible to create a cycle in the call stack.
// * the arguments and return values for main() are properly set (e.g., the segment
//   pointers).
// * the requested program is loaded, starting from initial_pc.
// * final_pc points to the end of the program.
// * program output is valid in any sense.
// * The continuous pages are consistent. See public_memory.cairo.
func public_input_validate{range_check_ptr}(
    air: AirWithLayout*, public_input: PublicInput*, stark_domains: StarkDomains*
) {
    alloc_locals;

    assert_nn_le(public_input.log_n_steps, MAX_LOG_N_STEPS);
    let (local n_steps) = pow(2, public_input.log_n_steps);
    tempvar trace_length = stark_domains.trace_domain_size;
    assert n_steps * CPU_COMPONENT_HEIGHT * CPU_COMPONENT_STEP = trace_length;

    assert_le(0, public_input.range_check_min);
    assert_le(public_input.range_check_min, public_input.range_check_max);
    assert_le(public_input.range_check_max, MAX_RANGE_CHECK);

    assert public_input.layout = LAYOUT_CODE;

    // Segments.
    let n_output_uses = (
        public_input.segments[segments.OUTPUT].stop_ptr -
        public_input.segments[segments.OUTPUT].begin_addr
    );
    assert_nn(n_output_uses);

    assert public_input.n_segments = segments.N_SEGMENTS;

    let n_pedersen_copies = trace_length / PEDERSEN_BUILTIN_ROW_RATIO;
    let n_pedersen_uses = (
        public_input.segments[segments.PEDERSEN].stop_ptr -
        public_input.segments[segments.PEDERSEN].begin_addr
    ) / 3;
    // Note that the following call implies that trace_length is divisible by
    // PEDERSEN_BUILTIN_ROW_RATIO
    // and that stop_ptr - begin_addr is divisible by 3.
    assert_nn_le(n_pedersen_uses, n_pedersen_copies);

    let n_range_check_copies = trace_length / RANGE_CHECK_BUILTIN_ROW_RATIO;
    let n_range_check_uses = (
        public_input.segments[segments.RANGE_CHECK].stop_ptr -
        public_input.segments[segments.RANGE_CHECK].begin_addr
    );
    // Note that the following call implies that trace_length is divisible by
    // RANGE_CHECK_BUILTIN_ROW_RATIO.
    assert_nn_le(n_range_check_uses, n_range_check_copies);

    let n_bitwise_copies = trace_length / BITWISE__ROW_RATIO;
    let n_bitwise_uses = (
        public_input.segments[segments.BITWISE].stop_ptr -
        public_input.segments[segments.BITWISE].begin_addr
    ) / 5;
    // Note that the following call implies that trace_length is divisible by
    // BITWISE__ROW_RATIO
    // and that stop_ptr - begin_addr is divisible by 5.
    assert_nn_le(n_bitwise_uses, n_bitwise_copies);

    return ();
}
