// Computes value / div as integers and fails if value is not divisible by div.
// Namely, verifies that 1 <= div < PRIME / rc_bound
// and returns q such that:
//   0 <= q < rc_bound and q = value / div.
func safe_div{range_check_ptr}(value: felt, div: felt) -> felt {
    // floor(PRIME / 2 ** 128).
    const PRIME_OVER_RC_BOUND = 0x8000000000000110000000000000000;
    assert [range_check_ptr] = div - 1;
    assert [range_check_ptr + 1] = div + (2 ** 128 - PRIME_OVER_RC_BOUND);
    // Prepare the result at the end of the stack.
    let q = [ap + 1];
    q = value / div;
    tempvar range_check_ptr = range_check_ptr + 3;
    [range_check_ptr - 1] = q, ap++;
    static_assert &q + 1 == ap;
    return q;
}

// Computes first * second if there is no overflow.
// Namely, returns the product of first and second if:
//   0 <= first < rc_bound and 0 <= second < PRIME / rc_bound
// and fails otherwise.
func safe_mult{range_check_ptr}(first: felt, second: felt) -> felt {
    // floor(PRIME / 2 ** 128).
    const PRIME_OVER_RC_BOUND = 0x8000000000000110000000000000000;
    assert [range_check_ptr] = first;
    assert [range_check_ptr + 1] = second;
    assert [range_check_ptr + 2] = second + (2 ** 128 - PRIME_OVER_RC_BOUND);
    let range_check_ptr = range_check_ptr + 3;
    return first * second;
}