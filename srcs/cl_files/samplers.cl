#include "random.cl"
static void			create_coordinate_system(float3 *normal, float3 *nt, float3 *nb)
{
	if (fabs(normal->x) > fabs(normal->y))
		*nt = (float3)(normal->z, 0., -1.f * normal->x);
	else
		*nt = (float3)(0., -1.f * normal->z, normal->y);
	*nt = normalize(*nt);
	*nb = cross(*normal, *nt);
}

static float3		convert_sample(float3 *normal, float3 *sample, float3 *nt, float3 *nb)
{
	return ((float3)
		{
			sample->x * nb->x + sample->y * normal->x + sample->z * nt->x,
			sample->x * nb->y + sample->y * normal->y + sample->z * nt->y,
			sample->x * nb->z + sample->y * normal->z + sample->z * nt->z
		});
}

static float3		sampler_transform(float3 *normal, float3 *sample)
{
	float3		nt;
	float3		nb;

	create_coordinate_system(normal, &nt, &nb);
	return (convert_sample(normal, sample, &nt, &nb));
}
//
static float3		sample_uniform
					(float3 *normal,
					float *cosine,
					global ulong *rng_state)
{
	float 			r[2];
	float3			sample;
	float			sin_theta;
	float			phi;

	r[0] = rng_lgc(rng_state);
	r[1] = rng_lgc(rng_state);
	sin_theta = sqrt(fmax(0.0f , 1.0f - r[0] * r[0]));
	phi = 2.0f * PI * r[1];
	*cosine = r[0];
	sample = (float3)
		{
			sin_theta * cos(phi),
			r[0],
			sin_theta * sin(phi)
		};
	return (sampler_transform(normal, &sample));
}