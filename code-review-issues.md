# CHMM-Model Code Review Issues

Review target: `/Users/jdv27/Desktop/julia_work/CHMM-Model`

## Findings

1. **Gaussian Baum-Welch returns a stale initial distribution**
   - Priority: P2
   - File: `/Users/jdv27/Desktop/julia_work/CHMM-Model/src/Compute.jl`
   - Location: around line 388
   - Issue: `baum_welch` never updates `curr_π`, so it always returns the uniform initial distribution even when the first-step posterior `γ[1, :]` is not uniform.
   - Evidence: A targeted probe returned `π = [0.5, 0.5]` while `gamma[1, :] = [1.0, ~0]`.
   - Impact: Gaussian CHMM callers receive an incorrect learned initial-state vector, and the Gaussian implementation is inconsistent with the Student-t, Laplace, and GED variants.

2. **HMM initializers fail when the number of states exceeds observation count**
   - Priority: P2
   - File: `/Users/jdv27/Desktop/julia_work/CHMM-Model/src/Compute.jl`
   - Location: around line 289 and analogous initializers for Laplace/GED/Student-t
   - Issue: the quantile/chunk initializer computes `chunk_size = floor(Int, N / K)`. When `K > N`, `chunk_size == 0`, creating empty chunks.
   - Evidence: With two observations and three states, Gaussian, Laplace, and GED fitting all error during initialization.
   - Impact: Small training windows or accidental over-specified state counts fail with low-level distribution/empty-array errors instead of a clear validation error.

3. **Standard Julia package test command fails**
   - Priority: P3
   - File: `/Users/jdv27/Desktop/julia_work/CHMM-Model/Project.toml`
   - Location: line 1
   - Issue: `Project.toml` has dependencies but no package `name` or `uuid`.
   - Evidence: `julia --project=. -e 'using Pkg; Pkg.test()'` fails with: `The Project.toml of the package being tested must have a name and a UUID entry`.
   - Impact: The direct runner works, but standard Julia package tooling and CI will fail unless tests are invoked manually.

4. **Weighted median docstring disagrees with implementation**
   - Priority: P3
   - File: `/Users/jdv27/Desktop/julia_work/CHMM-Model/src/Compute.jl`
   - Location: around line 596
   - Issue: `_weighted_median` says exact-half ties return the upper endpoint, but the code returns the first order statistic where cumulative weight reaches half.
   - Evidence: `_weighted_median([0.0, 10.0], [1.0, 1.0])` returns `0.0`, not `10.0`.
   - Impact: Both endpoints minimize the weighted L1 objective, so this is documentation/test clarity rather than a numerical correctness bug.

## Verification

- `julia --project=. test/runtests.jl` passed: 89 tests.
- `julia --project=. -e 'using Pkg; Pkg.test()'` failed because `Project.toml` lacks `name` and `uuid`.
- Targeted probes reproduced the Gaussian `π` issue and the `K > N` initializer failures.
