#include "options.cl"

static float ft_solve(float a, float b, float c)
{
	float  disc = b * b - 4*a*c;
   	float temp = 1/(2*a);
	float res;

 	if (disc < 0.0f) 
		return 0.0f;
	
	disc = sqrt(disc);
	if ((res = (-b - disc) * temp) > EPSILON)
		return res;
    if ((res = (-b + disc) * temp) > EPSILON)
		return res;
	return(0.f);
}

				/* (__global Sphere* sphere, t_ray* ray) */
static float intersect_cone(const t_obj* cone, t_ray* ray) /* version using local copy of sphere */
{
	float3	x = ray->origin - cone->position;
	float	a = dot(ray->direction, cone->v);
	float	c = dot(x, cone->v);
	float	temp = 1 + cone->radius * cone->radius;
	float	b = 2.0 * (dot(ray->direction, x) - temp * a * c);

	a = dot(ray->direction, ray->direction) - temp * a * a;
	c = dot(x, x) - temp * c * c;	
	return (ft_solve(a, b, c));
}

static float intersect_sphere(const t_obj* sphere, t_ray* ray) /* version using local copy of sphere */
{
	float3 rayToCenter = ray->origin - sphere->position;
    float a = 1;
    float b = 2*dot(rayToCenter, ray->direction);
    float c = dot(rayToCenter, rayToCenter) - sphere->radius*sphere->radius;	
	return (ft_solve(a, b, c));
}

double		intersect_plane(const t_obj* plane, t_ray* ray)
{
	double	a;
	double	b;
	a = dot(plane->position, ray->direction);//ft_vec3_dot_multiply(ft_vec3_substract(ray->orig, plane->point), plane->normal);
	//b = ft_vec3_dot_multiply(ray->direction, plane->normal);
	if (a == 0)
		return (0);
	b = -(dot(plane->position, ray->origin) + plane->plane_d) / a;
	return (b < EPSILON) ? 0 : b;
}

static double		intersect_cylinder(const t_obj* cylinder, t_ray* ray)
{
	float3	x = ray->origin - cylinder->position;
	double	a = dot(ray->direction, cylinder->v);
	double	c = dot(x, cylinder->v);
	double	b = 2 * (dot(ray->direction, x) - a * dot(x, cylinder->v));

	a = dot(ray->direction, ray->direction) - a * a;
	c = dot(x, x) - c * c - cylinder->radius * cylinder->radius;
	return (ft_solve(a, b, c));
}

