#pragma once

#ifdef _MSC_VER
#define INTERFACE_API __stdcall
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API
#error "Unsported compiler have fun"
#endif

#ifdef __cplusplus
extern "C"
{
#endif

	EXPORT_API void INTERFACE_API nerf_initialize(const char *scene, const char *snapshot, bool use_dlss);
	EXPORT_API void INTERFACE_API nerf_deinitialize();

	EXPORT_API unsigned int* INTERFACE_API nerf_create_texture(int num_views, float *fov, int width, int height);
	EXPORT_API void INTERFACE_API nerf_update_textures(float *camera_matrix, unsigned int *handle);

	EXPORT_API void INTERFACE_API nerf_set_fov(float val);
	EXPORT_API void INTERFACE_API nerf_update_aabb_crop(float* min_vec, float* max_vec);

#ifdef __cplusplus
}
#endif
