# Compiling the verifier

`cairo-compile src/main.cairo --output verifier.compiled.json`
This can take a while, the output file is 11GB.
The sha256 hash computed with:
`shasum -a 256 verifier_compiled.json`
Should be: `62c970167286141be3975d149069cacb1a28f61539557d39f4e8da7a29700d77`

# Running the verifier

`cairo-run --program=verifier_compiled.json --layout=recursive --program_input=verifier_from_cairo_lang.input.json --print_output`
Running the verifier can take long.
On a Macbook Pro M2 MAX it took 50minutes.

# Missing files

If you are missing some files pls ask Marcello
