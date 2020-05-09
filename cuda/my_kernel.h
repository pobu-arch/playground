__host__ void cpu_calc_xy(float* x, float* y, int width, int height, float scale, float imageAspectRatio)
{
    for (uint32_t j = 0; j < height; ++j)
    {
        for (uint32_t i = 0; i < width; ++i)
        {
#ifdef MAYA_STYLE
            float x = (2 * (i + 0.5) / (float)width - 1) * scale;
            float y = (1 - 2 * (j + 0.5) / (float)height) * scale * 1 / imageAspectRatio;
#elif

            float x = (2 * (i + 0.5) / (float)width - 1) * imageAspectRatio * scale;
            float y = (1 - 2 * (j + 0.5) / (float)height) * scale;
#endif
        }
    }
}

__global__ void gpu_calc_xy(float* x, float* y, const int width, const int height, const float scale, const float imageAspectRatio)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row >= height || col >= width) return;

#ifdef MAYA_STYLE
    x[row * width + col] = (2 * (row + 0.5) / (float)width - 1) * scale;
    y[row * width + col] = (1 - 2 * (col + 0.5) / (float)height) * scale * 1 / imageAspectRatio;
#elif
    //x[row * width + col] = (2 * (row + 0.5) / (float)width - 1) * imageAspectRatio * scale;
    //y[row * width + col] = (1 - 2 * (col + 0.5) / (float)height) * scale;
    x[row * width + col] = (2 * (row + 0.5) / (float)width - 1) * scale;
    y[row * width + col] = (1 - 2 * (col + 0.5) / (float)height) * scale * 1 / imageAspectRatio;
#endif
}
