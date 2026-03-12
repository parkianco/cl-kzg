# cl-kzg

Pure Common Lisp implementation of the KZG (Kate-Zaverucha-Goldberg) polynomial commitment scheme.

## Features

- **Zero dependencies** - completely standalone
- **Multiple curves** - BN254 and BLS12-381 support
- **Full KZG protocol** - setup, commit, open, verify
- **Batch operations** - batch open and verify
- **Polynomial arithmetic** - add, subtract, multiply, divide, evaluate

## Installation

```bash
cd ~/common-lisp/  # or ~/quicklisp/local-projects/
git clone https://github.com/parkianco/cl-kzg.git
```

```lisp
(asdf:load-system :cl-kzg)
```

## Quick Start

```lisp
(use-package :cl-kzg)

;; 1. Generate SRS (Structured Reference String)
(defvar *srs* (kzg-setup 16))  ; supports up to degree 16

;; 2. Create a polynomial f(x) = 3 + 2x + x^2
(defvar *poly* (make-polynomial #(3 2 1)))

;; 3. Commit to the polynomial
(defvar *commitment* (kzg-commit *srs* *poly*))

;; 4. Create opening proof at evaluation point z=5
(defvar *opening* (kzg-open *srs* *poly* 5))

;; 5. Verify the opening
(kzg-verify *srs* *commitment* *opening*)  ; => T
```

## API Reference

### Field Elements

- `make-field-element` - Create field element
- `field-add`, `field-sub`, `field-mul`, `field-div` - Arithmetic
- `field-inv`, `field-neg`, `field-exp` - Operations

### Elliptic Curve Points

- `make-g1-point`, `make-g2-point` - Create points
- `g1-add`, `g2-add` - Point addition
- `g1-scalar-mul`, `g2-scalar-mul` - Scalar multiplication
- `g1-generator`, `g2-generator` - Generator points

### Polynomials

- `make-polynomial` - Create from coefficients
- `poly-add`, `poly-sub`, `poly-mul` - Arithmetic
- `poly-eval` - Evaluate at point
- `poly-divide` - Polynomial division
- `poly-degree` - Get degree

### KZG Protocol

- `kzg-setup` - Generate SRS
- `kzg-commit` - Commit to polynomial
- `kzg-open` - Create opening proof
- `kzg-verify` - Verify opening
- `kzg-batch-open` - Batch opening
- `kzg-batch-verify` - Batch verification

### Commitment Operations

- `kzg-commitment-add` - Add commitments
- `kzg-commitment-scale` - Scale commitment

## Supported Curves

| Curve | Field Prime | Group Order |
|-------|-------------|-------------|
| BN254 | 21888242871839275222246405745257275088696311157297823662689037894645226208583 | 21888242871839275222246405745257275088548364400416034343698204186575808495617 |
| BLS12-381 | 52435875175126190479447740508185965837690552500527637822603658699938581184513 | 52435875175126190479447740508185965837690552500527637822603658699938581184513 |

## Mathematical Background

KZG commitments allow proving polynomial evaluations with O(1) proof size:

1. **Setup**: Generate powers of secret tau in G1 and G2
2. **Commit**: C = f(tau) * G1 (multi-scalar multiplication)
3. **Open**: Create proof pi for f(z) = y
4. **Verify**: Pairing check e(C - y*G1, G2) = e(pi, tau*G2 - z*G2)

## Testing

```lisp
(asdf:test-system :cl-kzg)
```

## License

BSD-3-Clause. See [LICENSE](LICENSE).

## Author

Parkian Company LLC
