static t_ray		camera_build_ray( t_camera *camera, int2 *screen)
{
	t_ray			result;
	float3			up;
	float3			right;
	float 			xf;
	float 			yf;

	xf = (float)screen->x;
	yf = (float)screen->y;
	result.origin = camera->position;
	up = (float3)camera->axis_y * (float)(-1.f * yf + (camera->height - 1.f) / 2.f);
	right = (float3)camera->axis_x * (float)(xf - (camera->width - 1.f) / 2.f);
	result.direction = up + right + camera->forward;
	result.direction = normalize(result.direction);
	return (result);
}