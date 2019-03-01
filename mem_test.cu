#include <stdio.h>
#include <thread>
#include <unistd.h>
#include <iostream>
#include <cuda_runtime.h>
#include <vector>

#define GRID_X  128
#define BLOCK_X 128

__global__ void proc(int *mem){
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    while(true){
        mem[idx]++;
    }
}


void run_thread()
{
    cudaSetDevice(0);
    //cudaStream_t s1;
    //cudaStreamCreate(&s1);
    int *pdata;
    cudaMallocManaged(&pdata,GRID_X*BLOCK_X);
    memset(pdata,0,sizeof(int)*GRID_X*BLOCK_X);
    sleep(1);
    std::cout << "start kernel in run_thread" << std::endl;
    //proc<<<GRID_X,BLOCK_X,0,s1>>>(pdata);
    //cudaStreamSynchronize(s1);
    proc<<<GRID_X,BLOCK_X>>>(pdata);
    cudaDeviceSynchronize();
    std::cout << "end kernel in run_thread" << std::endl;
}

void free_thread()
{
    cudaSetDevice(1);
    int *pdata;
    cudaMallocManaged(&pdata,GRID_X*BLOCK_X);
    sleep(5);
    std::cout << "start cudaFree in free_thread" << std::endl;
    cudaFree(pdata);
    std::cout << "end cudaFree in free_thread" << std::endl;
}


int main(){

    std::thread th0(&run_thread);
    std::thread th1(&free_thread);
    th0.join();
    th1.join();
    return 0;
}

