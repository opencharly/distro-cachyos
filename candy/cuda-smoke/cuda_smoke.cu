// Minimal deterministic CUDA compute smoke: allocate two vectors on the GPU,
// run a vector-add kernel, copy back, verify every element. Prints
// "CUDA-OK devices=<N>" and exits 0 on success; prints "CUDA-FAIL: <reason>"
// and exits 1 on any CUDA error or wrong result. Used by the GPU-passthrough
// eval to prove real device compute inside the VM (not just driver presence).
#include <cstdio>
#include <cuda_runtime.h>

__global__ void vadd(const float *a, const float *b, float *c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) c[i] = a[i] + b[i];
}

#define CK(call)                                                        \
    do {                                                                \
        cudaError_t _e = (call);                                        \
        if (_e != cudaSuccess) {                                        \
            printf("CUDA-FAIL: %s: %s\n", #call, cudaGetErrorString(_e)); \
            return 1;                                                   \
        }                                                               \
    } while (0)

int main(void) {
    int devices = 0;
    cudaError_t e = cudaGetDeviceCount(&devices);
    if (e != cudaSuccess || devices < 1) {
        printf("CUDA-FAIL: no device: %s\n", cudaGetErrorString(e));
        return 1;
    }

    const int n = 1 << 20;
    const size_t bytes = (size_t)n * sizeof(float);
    float *ha = (float *)malloc(bytes), *hb = (float *)malloc(bytes), *hc = (float *)malloc(bytes);
    for (int i = 0; i < n; i++) { ha[i] = 1.0f; hb[i] = 2.0f; }

    float *da, *db, *dc;
    CK(cudaMalloc(&da, bytes));
    CK(cudaMalloc(&db, bytes));
    CK(cudaMalloc(&dc, bytes));
    CK(cudaMemcpy(da, ha, bytes, cudaMemcpyHostToDevice));
    CK(cudaMemcpy(db, hb, bytes, cudaMemcpyHostToDevice));

    int threads = 256, blocks = (n + threads - 1) / threads;
    vadd<<<blocks, threads>>>(da, db, dc, n);
    CK(cudaGetLastError());
    CK(cudaDeviceSynchronize());
    CK(cudaMemcpy(hc, dc, bytes, cudaMemcpyDeviceToHost));

    for (int i = 0; i < n; i++) {
        if (hc[i] != 3.0f) {
            printf("CUDA-FAIL: bad result at %d: %f\n", i, hc[i]);
            return 1;
        }
    }
    printf("CUDA-OK devices=%d\n", devices);
    return 0;
}
