#include "kernel.hl"

float3			get_color_sphere(t_obj object, float3 hitpoint, t_scene *scene)
{
	float3		vect;
	__global t_txture	*texture;
	float		u;
	float		v;
	int			i;

	vect = normalize(hitpoint - object.position);
	/*FOR SVIBORG*/
	u = vect.z;
	vect.z = vect.x;
	vect.x = u;
	u = 0.5 + (atan2(vect.z, vect.x)) / (2 * PI);
	v = 0.5 - (asin(vect.y)) / PI;
	texture = &((scene->textures)[object.texture - 1]);
	i = ((int)(v * (float)(texture->height - 1))) * (texture->width) + (int)(u * (float)(texture->width - 1));
	return(cl_int_to_float3(texture->texture[i]));
}

float3			get_color_plane(t_obj object, float3 hitpoint, t_scene *scene)
{
	float3		vect;
	float3      secvect;
	__global t_txture	*texture;
	float		u;
	float		v;
	int			i;

	if (object.v.x != 0.0f || object.v.y != 0.0f)
		vect = normalize((float3){object.v.y, -object.v.x, 0});
	else
		vect = (float3){0.0f, 1.0f, 0.0f};
	secvect = cross(vect, object.v);
	u = 0.5 + dot(vect, hitpoint) / 2;
	v = 0.5 + dot(secvect, hitpoint) / 2;
	texture = &((scene->textures)[object.texture - 1]);
	i = ((int)(v * (float)(texture->height - 1))) * (texture->width) + (int)(u * (float)(texture->width - 1));
	return(cl_int_to_float3(texture->texture[i]));
}

float3          get_color_cylinder(t_obj object, float3 hitpoint, t_scene *scene)
{
	float3		vect;
	__global t_txture	*texture;
	float		u;
	float		v;
	int			i;

	vect = normalize(hitpoint - object.position);
	// u = 0.5 + (atan2(vect[2], vect[0])) / (2 * PI);
	u = 0.5 + (atan2(vect.z, vect.x)) / (2 * PI);
	texture = &((scene->textures)[object.texture - 1]);
	v = 0.5 + modf(hitpoint.y * 1000 / texture->height, &v) / 2;
	// v = v < 0 ? 1 + v : v;
	// printf("%f\n", v);
	i = ((int)(v * (float)(texture->height - 1))) * (texture->width) + (int)(u * (float)(texture->width - 1));
	return(cl_int_to_float3(texture->texture[i]));
}

float3			get_color(t_obj object, float3 hitpoint, t_scene *scene)
{
	if (object.texture > 0)
	{
		if (object.type == SPHERE)
			return(get_color_sphere(object, hitpoint, scene));
		if (object.type == CYLINDER)
			return(get_color_cylinder(object, hitpoint, scene));
		if (object.type == PLANE)
			return(get_color_plane(object, hitpoint, scene));
		return (object.color);
	}
	else
		return (object.color);
}