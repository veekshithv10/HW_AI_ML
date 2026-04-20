%%writefile gemm_tiled.cu
#include <iostream>
#include <cuda_runtime.h>

// Matrix size: 1024 x 1024
#define N 1024
// Tile Size: 8 (as requested in the instructions)
#define TILE_SIZE 8

// This is the Tiled CUDA Kernel
__global__ void gemm_tiled(const float *A, const float *B, float *C, int n) {
    // Allocate fast shared memory for our tiles (The "Pantry")
    __shared__ float As[TILE_SIZE][TILE_SIZE];
    __shared__ float Bs[TILE_SIZE][TILE_SIZE];

    // Thread coordinates
    int tx = threadIdx.x; 
    int ty = threadIdx.y;

    // Calculate global row and col
    int row = blockIdx.y * TILE_SIZE + ty;
    int col = blockIdx.x * TILE_SIZE + tx;

    float sum = 0.0f;

    // Slide across the matrix in TILE chunks
    for (int t = 0; t < n / TILE_SIZE; ++t) {
        
        // 1. Fetch a tile from slow DRAM and put it into fast shared memory
        As[ty][tx] = A[row * n + (t * TILE_SIZE + tx)];
        Bs[ty][tx] = B[(t * TILE_SIZE + ty) * n + col];

        // 2. Wait for all threads in the block to finish stocking the pantry
        __syncthreads();

        // 3. Do the "Two Finger" math using only the fast shared memory!
        for (int k = 0; k < TILE_SIZE; ++k) {
            sum += As[ty][k] * Bs[k][tx];
        }

        // 4. Wait for all threads to finish the math before loading the next tile
        __syncthreads();
    }

    // Write the final computed answer back to the output matrix C
    if (row < n && col < n) {
        C[row * n + col] = sum;
    }
}

int main() {
    size_t bytes = N * N * sizeof(float);

    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_C = (float*)malloc(bytes);

    for (int i = 0; i < N * N; ++i) {
        h_A[i] = 1.0f;
        h_B[i] = 1.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Organize the GPU threads into 8x8 blocks to match our Tile Size
    dim3 threadsPerBlock(TILE_SIZE, TILE_SIZE);
    dim3 numBlocks((N + TILE_SIZE - 1) / TILE_SIZE,
                   (N + TILE_SIZE - 1) / TILE_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    // Tell the GPU to run the tiled kernel
    gemm_tiled<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    double total_flops = 2.0 * N * N * N;
    double seconds = milliseconds / 1000.0;
    double gflops = (total_flops / 1e9) / seconds;

    std::cout << "--- TILED GEMM RESULTS ---\n";
    std::cout << "Matrix Size: " << N << "x" << N << "\n";
    std::cout << "Tile Size: " << TILE_SIZE << "x" << TILE_SIZE << "\n";
    std::cout << "Execution Time: " << milliseconds << " ms\n";
    std::cout << "Achieved Speed: " << gflops << " GFLOP/s\n";

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);

    return 0;
}