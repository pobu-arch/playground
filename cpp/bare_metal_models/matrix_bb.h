#ifndef MATRIX_BB_H
#define MATRIX_BB_H

#include<cstddef>
#include<cstdint>

#ifdef CXXLIB_ENABLED
    #include<string>
#endif

/*
 * A simple `Matrix` type optimized for low-overhead.
 * 
 * This struct supports "list-initialization", so that Matrices can be 
 * defined like `Matrix<int, 2, 2> = {{ {1, 2}, {3, 4} }}`.
 */
template<typename T, size_t H, size_t W>
struct Matrix
{
public:
    using Type = Matrix<T, H, W>;

public:
    T data[H][W];

    /* Factory functions */
    static constexpr Matrix<T, H, W> Zeros() {
        return Matrix();
    }
    static constexpr Matrix<T, H, W> Ones() {
        Matrix m;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                m[i][j] = 1;
            }
        }
        return m;
    }
    
    static constexpr Matrix<T, H, W> FromCArray(const T arr[H][W])
    {
        Matrix m;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                m[i][j] = arr[i][j];
            }
        }
        return m;
    }

    /* Dimensions */
    static constexpr size_t Height() { return H; }
    static constexpr size_t Width()  { return W; }

    /* Accessors */
    auto operator[](size_t i) {
        return data[i];
    }

    T elem(size_t i, size_t j) const {
        return data[i][j];
    }

    /* Mathematical operations */
    Matrix<T, H, W> operator+(const Matrix<T, H, W>& m2) const {
        Matrix<T, H, W> result;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                result[i][j] = elem(i, j) + m2.elem(i, j);
            }
        }
        return result;
    }

    template<size_t Q>
    Matrix<T, H, Q> MatMul(const Matrix<T, W, Q>& m2) const {
        Matrix<T, H, Q> result;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < Q; j++) {
                T acc = 0;
                for (size_t k = 0; k < W; k++) {
                    acc += elem(i, k) * m2.elem(k, j);
                }
                result[i][j] = acc;
            }
        }
        return result;
    }

    Matrix<T, W, H> Transpose() const {
        Matrix<T, W, H> result;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                result[j][i] = elem(i, j);
            }
        }
        return result;
    }

    Matrix<T, H, W> ReLU() const {
        Matrix<T, H, W> result;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                result[i][j] = (elem(i, j) > 0) ? elem(i, j) : 0;
            }
        }
        return result;
    }

    /* Comparison operators */
    bool operator==(const Matrix<T, H, W>& m2) const {
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                if (elem(i, j) != m2.elem(i, j)) {
                    return false;
                }
            }
        }
        return true;
    }

    bool operator!=(const Matrix<T, H, W>& m2) const {
        return !(*this == m2);
    }

#ifdef CXXLIB_ENABLED
    /* Representation */
    std::string ToString() const {
        std::string repr;
        for (size_t i = 0; i < H; i++) {
            for (size_t j = 0; j < W; j++) {
                repr += std::to_string(elem(i, j));
                if (j + 1 < W) repr += ", ";
            }
            repr += "\n";
        }
        return repr;
    }
#endif
};

/*
 * A simple two-layer MLP supporting list initialization.
 */
template <typename T, size_t I, size_t M, size_t O>
struct TwoLayerPerceptron
{
public:
    Matrix<T, M, I> w1;
    Matrix<T, M, 1> b1;
    Matrix<T, O, M> w2;
    Matrix<T, O, 1> b2;

    /* Data flow */
    Matrix<T, O, 1> Forward(const Matrix<T, I, 1> &input) const
    {
        // Single statement to prevent creation of temporaries
        return (w2.MatMul((w1.MatMul(input) + b1).ReLU()) + b2).ReLU();
    }
};

#endif // MATRIX_BB_H
