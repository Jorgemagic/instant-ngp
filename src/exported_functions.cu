#include "neural-graphics-primitives/exported_functions.h"

#ifdef _WIN32
#include <GL/gl3w.h>
#else
#include <GL/glew.h>
#endif
#include <GLFW/glfw3.h>
#include "gl/GL.h"
#include "gl/GLU.h"

#include <neural-graphics-primitives/adam_optimizer.h>
#include <neural-graphics-primitives/camera_path.h>
#include <neural-graphics-primitives/common.h>
#include <neural-graphics-primitives/discrete_distribution.h>
#include <neural-graphics-primitives/nerf.h>
#include <neural-graphics-primitives/nerf_loader.h>
#include <neural-graphics-primitives/render_buffer.h>
#include <neural-graphics-primitives/sdf.h>
#include <neural-graphics-primitives/shared_queue.h>
#include <neural-graphics-primitives/trainable_buffer.cuh>
#include <neural-graphics-primitives/testbed.h>
#include <neural-graphics-primitives/common_device.cuh>
#include <neural-graphics-primitives/common.h>
#include <neural-graphics-primitives/render_buffer.h>
#include <neural-graphics-primitives/tinyexr_wrapper.h>

#include <tiny-cuda-nn/gpu_memory.h>
#include <filesystem/path.h>
#include <cuda_gl_interop.h>

#include <tiny-cuda-nn/multi_stream.h>
#include <tiny-cuda-nn/random.h>

#include <json/json.hpp>
#include <filesystem/path.h>
#include <thread>
#include "gl/GL.h"
#include "gl/GLU.h"
#include <memory>

using Texture = std::shared_ptr<ngp::GLTexture>;
using RenderBuffer = std::shared_ptr<ngp::CudaRenderBuffer>;

struct TextureData
{
	TextureData(const Texture &tex, const RenderBuffer &buf, int width, int heigth)
		: surface_texture(tex), render_buffer(buf), width(width), height(height)
	{
	}

	Texture surface_texture;
	RenderBuffer render_buffer;
	int width;
	int height;
};

static bool already_initalized = false;
static bool use_dlss = false;
static std::shared_ptr<ngp::Testbed> testbed = nullptr;
static std::unordered_map<GLuint, std::shared_ptr<TextureData>> textures;

extern "C" void nerf_initialize(const char *scene, const char *snapshot, bool dlss)
{
	if (already_initalized)
	{
		std::cout << "Already initalized nerf" << std::endl;
		return;
	}

	use_dlss = dlss;
	already_initalized = true;

	testbed = std::make_shared<ngp::Testbed>(
		ngp::ETestbedMode::Nerf,
		scene);

	if (snapshot)
	{
		testbed->load_snapshot(
			snapshot);
	}

	if (!glfwInit())
	{
		std::cout << "Could not initialize glfw" << std::endl;
	}
	if (!gl3wInit())
	{
		std::cout << "Could not initialize gl3w" << std::endl;
	}

#ifdef NGP_VULKAN
	if (use_dlss)
	{
		try
		{
			testbed->m_dlss_provider = ngp::init_vulkan_and_ngx();
			if (testbed->m_testbed_mode == ngp::ETestbedMode::Nerf)
			{
				testbed->m_dlss = true;
			}
		}
		catch (std::runtime_error exception)
		{
			std::cout << "Could not initialize vulkan" << std::endl;
		}
	}
#endif
}

extern "C" unsigned int* nerf_create_textures(int num_views, float *fov, int width, int height)
{
	testbed->set_n_views(num_views);

	GLuint handles[2];

	return handles;
}

extern "C" void nerf_update_textures(float *camera_matrix, unsigned int *handle)
{
	if (!testbed)
		return;	
}

extern "C" void nerf_deinitialize()
{
	testbed->m_dlss = false;
	testbed->m_dlss_provider.reset();
	already_initalized = false;
	testbed.reset();
	glfwTerminate();
}


extern "C" void nerf_set_fov(float val)
{
	if (!testbed)
		return;

	testbed->set_fov(val);
}

extern "C" void nerf_update_aabb_crop(float* min_vec, float* max_vec)
{
	if (!testbed)
		return;

	Eigen::Vector3f min_aabb{ min_vec };
	Eigen::Vector3f max_aabb{ max_vec };

	testbed->m_render_aabb = ngp::BoundingBox(min_aabb, max_aabb);
}


