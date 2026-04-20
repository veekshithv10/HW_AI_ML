%%writefile gemm_naive.cu
#include <iostream>
#include <cuda_runtime.h>

// Matrix size: 1024 x 1024 (as requested in the instructions)
#define N 1024

// This is the Naive CUDA Kernel
__global__ void gemm_naive(const float *A, const float *B, float *C, int n) {
    // Calculate global row and column for this specific thread
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    // Check boundary conditions to prevent crashing
    if (row < n && col < n) {
        float sum = 0.0f;
        // The Naive Loop! It does N reads from A and N reads from B 
        // to calculate a single output number.
        for (int k = 0; k < n; ++k) {
            sum += A[row * n + k] * B[k * n + col];
        }
        C[row * n + col] = sum;
    }
}

int main() {
    size_t bytes = N * N * sizeof(float);

    // Allocate memory on Host (Your CPU's standard RAM)
    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_C = (float*)malloc(bytes);

    // Fill matrices A and B with dummy numbers (1.0)
    for (int i = 0; i < N * N; ++i) {
        h_A[i] = 1.0f;
        h_B[i] = 1.0f;
    }

    // Allocate memory on Device (The GPU's VRAM)
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    // Copy the matrices from the slow CPU to the GPU
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Organize the GPU threads into 16x16 blocks
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((N + threadsPerBlock.x - 1) / threadsPerBlock.x,
                   (N + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // Setup CUDA events to measure exactly how long the math takes
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Start the stopwatch!
    cudaEventRecord(start);

    // Tell the GPU to run the naive kernel
    gemm_naive<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);

    // Stop the stopwatch!
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    // Calculate time elapsed
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    // Calculate GFLOP/s (Giga-Floating Point Operations per Second)
    // Math rule: A dot product requires 2 operations (multiply and add) * N^3
    double total_flops = 2.0 * N * N * N;
    double seconds = milliseconds / 1000.0;
    double gflops = (total_flops / 1e9) / seconds;

    // Print the results for Task 3
    std::cout << "--- NAIVE GEMM RESULTS ---\n";
    std::cout << "Matrix Size: " << N << "x" << N << "\n";
    std::cout << "Execution Time: " << milliseconds << " ms\n";
    std::cout << "Achieved Speed: " << gflops << " GFLOP/s\n";

    // Clean up memory to be polite
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);

    return 0;
}