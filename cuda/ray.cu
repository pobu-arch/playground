#include <cstdio>
#include <cstdlib>
#include <memory>
#include <vector>
#include <utility>
#include <cstdint>
#include <iostream>
#include <fstream>
#include <cmath>
#include <limits>
#include <random>
#include <ctime>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
using namespace std;

#include "geometry.h"
#include "my_kernel.h"

#define OBJ_NUM 256
#define SCREEN_WIDTH 3600
#define SCREEN_HEIGHT 3600

#define GPU
#ifdef GPU
#define BlockDim 32
#define GridDim  (SCREEN_WIDTH / BlockDim + 1)
#endif

const float kInfinity = std::numeric_limits<float>::max();
std::random_device rd;
std::mt19937 gen(rd());
std::uniform_real_distribution<> dis(0, 1);

inline
float clamp(const float& lo, const float& hi, const float& v)
{
    return std::max(lo, std::min(hi, v));
}

inline
float deg2rad(const float& deg)
{
    return deg * 3.1415926 / 180;
}

inline
Vec3f mix(const Vec3f& a, const Vec3f& b, const float& mixValue)
{
    return a * (1 - mixValue) + b * mixValue;
}

struct Options
{
    uint32_t width;
    uint32_t height;
    float fov;
    Matrix44f cameraToWorld;
};

// [comment]
// Object base class
// [/comment]
class Object
{
public:
    Object() : color(dis(gen), dis(gen), dis(gen)) {}
    virtual ~Object() {}
    // Method to compute the intersection of the object with a ray
    // Returns true if an intersection was found, false otherwise
    // See method implementation in children class for details
    virtual bool intersect(const Vec3f&, const Vec3f&, float&) const = 0;
    // Method to compute the surface data such as normal and texture coordnates at the intersection point.
    // See method implementation in children class for details
    virtual void getSurfaceData(const Vec3f&, Vec3f&, Vec2f&) const = 0;
    Vec3f color;
};

// [comment]
// Compute the roots of a quadratic equation
// [/comment]
bool solveQuadratic(const float& a, const float& b, const float& c, float& x0, float& x1)
{
    float discr = b * b - 4 * a * c;
    if (discr < 0) return false;
    else if (discr == 0) {
        x0 = x1 = -0.5 * b / a;
    }
    else {
        float q = (b > 0) ?
            -0.5 * (b + sqrt(discr)) :
            -0.5 * (b - sqrt(discr));
        x0 = q / a;
        x1 = c / q;
    }

    return true;
}

// [comment]
// Sphere class. A sphere type object
// [/comment]
class Sphere : public Object
{
public:
    Sphere(const Vec3f& c, const float& r) : radius(r), radius2(r* r), center(c) {}
    // [comment]
    // Ray-sphere intersection test
    //
    // \param orig is the ray origin
    //
    // \param dir is the ray direction
    //
    // \param[out] is the distance from the ray origin to the intersection point
    //
    // [/comment]
    bool intersect(const Vec3f& orig, const Vec3f& dir, float& t) const
    {
        float t0, t1; // solutions for t if the ray intersects
#if 0
        // geometric solution
        Vec3f L = center - orig;
        float tca = L.dotProduct(dir);
        if (tca < 0) return false;
        float d2 = L.dotProduct(L) - tca * tca;
        if (d2 > radius2) return false;
        float thc = sqrt(radius2 - d2);
        t0 = tca - thc;
        t1 = tca + thc;
#else
        // analytic solution
        Vec3f L = orig - center;
        float a = dir.dotProduct(dir);
        float b = 2 * dir.dotProduct(L);
        float c = L.dotProduct(L) - radius2;
        if (!solveQuadratic(a, b, c, t0, t1)) return false;
#endif
        if (t0 > t1) std::swap(t0, t1);

        if (t0 < 0) {
            t0 = t1; // if t0 is negative, let's use t1 instead
            if (t0 < 0) return false; // both t0 and t1 are negative
        }

        t = t0;

        return true;
    }
    // [comment]
    // Set surface data such as normal and texture coordinates at a given point on the surface
    //
    // \param Phit is the point ont the surface we want to get data on
    //
    // \param[out] Nhit is the normal at Phit
    //
    // \param[out] tex are the texture coordinates at Phit
    //
    // [/comment]
    void getSurfaceData(const Vec3f& Phit, Vec3f& Nhit, Vec2f& tex) const
    {
        Nhit = Phit - center;
        Nhit.normalize();
        // In this particular case, the normal is simular to a point on a unit sphere
        // centred around the origin. We can thus use the normal coordinates to compute
        // the spherical coordinates of Phit.
        // atan2 returns a value in the range [-pi, pi] and we need to remap it to range [0, 1]
        // acosf returns a value in the range [0, pi] and we also need to remap it to the range [0, 1]
        tex.x = (1 + atan2(Nhit.z, Nhit.x) / 3.1415926) * 0.5;
        tex.y = acosf(Nhit.y) / 3.1415926;
    }
    float radius, radius2;
    Vec3f center;
};

// [comment]
// Returns true if the ray intersects an object. The variable tNear is set to the closest intersection distance and hitObject
// is a pointer to the intersected object. The variable tNear is set to infinity and hitObject is set null if no intersection
// was found.
// [/comment]
bool trace(const Vec3f& orig, const Vec3f& dir, const std::vector<std::unique_ptr<Object>>& objects, float& tNear, const Object*& hitObject)
{
    tNear = kInfinity;
    std::vector<std::unique_ptr<Object>>::const_iterator iter = objects.begin();
    for (; iter != objects.end(); ++iter) {
        float t = kInfinity;
        if ((*iter)->intersect(orig, dir, t) && t < tNear) {
            hitObject = iter->get();
            tNear = t;
        }
    }

    return (hitObject != nullptr);
}

// [comment]
// Compute the color at the intersection point if any (returns background color otherwise)
// [/comment]
Vec3f castRay(
    const Vec3f& orig, const Vec3f& dir,
    const std::vector<std::unique_ptr<Object>>& objects)
{
    Vec3f hitColor = 0;
    const Object* hitObject = nullptr; // this is a pointer to the hit object
    float t; // this is the intersection distance from the ray origin to the hit point
    if (trace(orig, dir, objects, t, hitObject))
    {
        Vec3f Phit = orig + dir * t;
        Vec3f Nhit;
        Vec2f tex;
        hitObject->getSurfaceData(Phit, Nhit, tex);
        // Use the normal and texture coordinates to shade the hit point.
        // The normal is used to compute a simple facing ratio and the texture coordinate
        // to compute a basic checker board pattern
        float scale = 4;
        float pattern = (fmodf(tex.x * scale, 1) > 0.5) ^ (fmodf(tex.y * scale, 1) > 0.5);
        hitColor = std::max(0.f, Nhit.dotProduct(-dir)) * mix(hitObject->color, hitObject->color * 0.8, pattern);
    }

    return hitColor;
}

// [comment]
// The main render function. This where we iterate over all pixels in the image, generate
// primary rays and cast these rays into the scene. The content of the framebuffer is
// saved to a file.
// [/comment]
void render(
    const Options& options,
    const std::vector<std::unique_ptr<Object>>& objects)
{

#ifdef GPU

    int Block_Dim = BlockDim;
    int Grid_Dim = GridDim;

    if (Block_Dim * Block_Dim > 1024)
    {
        cout << "[Error] too many threads in block" << endl;
        exit(-1);
    }

    if (Grid_Dim * Block_Dim < options.width)
    {
        cout << "[Error] number of threads in x/y dimensions less than number of array elements" << endl;
        exit(-1);
    }

    cout << "Screen Dimension (x, y) = (" << options.width << ", " << options.height << ")" << endl;

    clock_t start = clock();

    Vec3f* dev_dir;
    float* dev_camera;
    Vec3f* host_dir;
    int gpu_count;

    cudaError_t errorcode = cudaGetDeviceCount(&gpu_count);
    if (errorcode == cudaErrorNoDevice)
    {
        cout << "[Error] No GPUs are visible" << endl;
        exit(-1);
    }
    else cudaSetDevice(0);

    errorcode = cudaMalloc((void**)&dev_dir, options.width * options.height * sizeof(Vec3f)); // allocate memory on device
    if (errorcode != cudaSuccess)
    {
        cout << "[Error] Not enough GPU memory for dev_dir" << endl;
    }

    errorcode = cudaMalloc((void**)&dev_camera, 4 * 4 * sizeof(float)); // allocate memory on device
    if (errorcode != cudaSuccess)
    {
        cout << "[Error] Not enough GPU memory for dev_camera" << endl;
    }

    dim3 DimGrid(ceil(options.height / BlockDim), ceil(options.width / BlockDim), 1);
    dim3 DimBlock(BlockDim, BlockDim, 1);
    printf("Block_Dim = %d, Grid_Dim = %d\n", Block_Dim, Grid_Dim);

    float scale = tan(deg2rad(options.fov * 0.5));
    float imageAspectRatio = options.width / (float)options.height;

    Vec3f orig;
    options.cameraToWorld.multVecMatrix(Vec3f(0), orig);
    float* host_camera = new float[4 * 4];
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
        {
            host_camera[i * 4 + j] = options.cameraToWorld.x[i][j];
        }
    cudaMemcpyToSymbol(dev_camera, host_camera, 4 * 4 * sizeof(float), cudaMemcpyHostToDevice);
    
    Vec3f* framebuffer = new Vec3f[options.width * options.height];

    cout << "Begin GPU computation on dev_dir" << endl;
    gpu_calc_xy <<<DimGrid, DimBlock >>> (dev_dir, dev_camera, options.width, options.height, scale, imageAspectRatio);
    cout << "Complete GPU computation on dev_x and dev_y" << endl;

    host_dir = new Vec3f[options.width * options.height]; // dynamically allocated memory for arrays on host

    cudaMemcpy(host_dir, dev_dir, options.width * options.height * sizeof(Vec3f), cudaMemcpyDeviceToHost);
    cout << "Complete GPU results copyback" << endl;

    clock_t end = clock();

    printf("GPU calc Time: %f s.\n", (1.0 * end - start) / CLOCKS_PER_SEC); // exec. time

    #pragma omp parallel for
    for (uint32_t j = 0; j < options.height; ++j)
    {
        for (uint32_t i = 0; i < options.width; ++i)
        {
            framebuffer[j * options.width + i] = castRay(orig, host_dir[j * options.width + i], objects);
        }
    }
    cout << "Complete Ray casting" << endl;

#else
    Vec3f* framebuffer = new Vec3f[options.width * options.height];
    Vec3f* pix = framebuffer;
    float scale = tan(deg2rad(options.fov * 0.5));
    float imageAspectRatio = options.width / (float)options.height;
    // [comment]
    // Don't forget to transform the ray origin (which is also the camera origin
    // by transforming the point with coordinates (0,0,0) to world-space using the
    // camera-to-world matrix.
    // [/comment]
    Vec3f orig;
    options.cameraToWorld.multVecMatrix(Vec3f(0), orig);
    for (uint32_t j = 0; j < options.height; ++j)
    {
        for (uint32_t i = 0; i < options.width; ++i)
        {
            float x = (2 * (i + 0.5) / (float)options.width - 1) * scale;
            float y = (1 - 2 * (j + 0.5) / (float)options.height) * scale * 1 / imageAspectRatio;
            Vec3f dir;
            options.cameraToWorld.multDirMatrix(Vec3f(x, y, -1), dir);
            dir.normalize();
            *(pix++) = castRay(orig, dir, objects);
        }
    }
#endif

    // Save result to a PPM image (keep these flags if you compile under Windows)
    std::ofstream ofs("./out.ppm", std::ios::out | std::ios::binary);
    ofs << "P6\n" << options.width << " " << options.height << "\n255\n";
    for (uint32_t i = 0; i < options.height * options.width; ++i) {
        char r = (char)(255 * clamp(0, 1, framebuffer[i].x));
        char g = (char)(255 * clamp(0, 1, framebuffer[i].y));
        char b = (char)(255 * clamp(0, 1, framebuffer[i].z));
        ofs << r << g << b;
    }

    ofs.close();

    delete[] framebuffer;
}

// [comment]
// In the main function of the program, we create the scene (create objects)
// as well as set the options for the render (image widht and height etc.).
// We then call the render function().
// [/comment]
int main(int argc, char** argv)
{
    clock_t start = clock();
    
    // creating the scene (adding objects and lights)
    std::vector<std::unique_ptr<Object>> objects;

    // generate a scene made of random spheres
    uint32_t numSpheres = OBJ_NUM;
    gen.seed(0);
    for (uint32_t i = 0; i < numSpheres; ++i)
    {
        Vec3f randPos((0.5 - dis(gen)) * 10, (0.5 - dis(gen)) * 10, (0.5 + dis(gen) * 10));
        float randRadius = (0.5 + dis(gen) * 0.5);
        objects.push_back(std::unique_ptr<Object>(new Sphere(randPos, randRadius)));
    }

    // setting up options
    Options options;
    options.width = SCREEN_WIDTH;
    options.height = SCREEN_HEIGHT;
    options.fov = 51.52;
    options.cameraToWorld = Matrix44f(0.945519, 0, -0.325569, 0, -0.179534, 0.834209, -0.521403, 0, 0.271593, 0.551447, 0.78876, 0, 4.208271, 8.374532, 17.932925, 1);

    // finally, render
    render(options, objects);

    clock_t end = clock();

    printf("Overall Time: %f s.\n", (1.0 * end - start) / CLOCKS_PER_SEC); // exec. time

    return 0;
}

