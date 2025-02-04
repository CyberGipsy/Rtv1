/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sbrella <sbrella@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2019/05/22 15:34:45 by sdurgan           #+#    #+#             */
/*   Updated: 2019/09/02 15:57:45 by sbrella          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "rtv1.h"
#include <time.h>
#include "libsdl.h"
#include "libvect.h"
#include "libcl.h"

//#define FPS

t_game game;
float xa, ya, za;

/*
*	Funtion: handles presses mouse/keyboard
* 	Return: value, doesnt change any parameters
*
*	- can handle multiple presses at once
*	- that goes into libsdl void ft_input(void *main, int (*f)(void *main, SDL_Event *ev))
*/
int		ft_input_keys(void *sdl, SDL_Event *ev)
{
	switch (ev->type)
		{
			case SDL_KEYDOWN:
			case SDL_KEYUP:
				switch (ev->key.keysym.sym)
				{
					case SDLK_LCTRL:
					case SDLK_RCTRL:
					case SDLK_ESCAPE: ft_exit(NULL); break;
					case 'w': game.wsad[0] = ev->type==SDL_KEYDOWN; break;
					case 's': game.wsad[1] = ev->type==SDL_KEYDOWN; break;
					case 'a': game.wsad[2] = ev->type==SDL_KEYDOWN; break;
					case 'd': game.wsad[3] = ev->type==SDL_KEYDOWN; break;
					case 'q': game.wsad[4] = ev->type==SDL_KEYDOWN; break;
					case 'e': game.wsad[5] = ev->type==SDL_KEYDOWN; break;
					case 'z': game.wsad[6] = ev->type==SDL_KEYDOWN; break;
					case 'x': game.wsad[7] = ev->type==SDL_KEYDOWN; break;
					case 'p': ya+=0.2; break;
					case ';': ya-=0.2; break;
					case SDLK_LEFT: xa+=0.05; break;
					case SDLK_RIGHT: xa-=0.05; break;
					default: break;
				}
				break;
			case SDL_MOUSEBUTTONDOWN:
				switch (ev->button.button)
				{
					case 1:	
						game.wsad[8] = ev->type == SDL_MOUSEBUTTONDOWN;
						process_left_click(ev->button.x, ev->button.y, game.gpu); break;  
					case 3:	printf("clicked right\n"); break;  
					default: break;

				}
				break;
			case SDL_QUIT: ft_exit(NULL);
		}
	return (1);
}

static float u_clamp(float x)
{
	return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x;
}

static int toInt(float x)
{ 
	return (int)(u_clamp(x) * 255);
}

 int getSurroundingAverage(t_game * game, int x, int y)
 {
	unsigned int index = ( game->sdl->surface->height - y - 1) *  game->sdl->surface->width + x;
	cl_float3 avg;
	cl_float3 temp;
    int total = 1;
	int color = 0;
	// if(x == 0 || y == 0)
	// 	return 0;
	for (int j = y - 1; j < y + 1; j++)
	{
		for (int k = x - 1; k < x + 1; k++)
		{
			temp =  game->gpu->vec_temp[k + j * game->sdl->surface->width];
			avg = (cl_float3){(avg.v4[0] + temp.v4[0]), (avg.v4[1] + temp.v4[1]), (avg.v4[2] + temp.v4[2])};
			total++;
		}
	}
	//avg = game->sdl->surface->data[x + y * game->sdl->surface->width];
    return ft_rgb_to_hex(toInt(avg.v4[0] / total), toInt(avg.v4[1]/ total), toInt(avg.v4[2]/ total));
  }

void ft_filter(t_game* game)
{
	int		i;
	int		j;
	int width = game->sdl->surface->width;
	int height = game->sdl->surface->height;
	j = 0;
	while (++j < height)
	{
		i = 0;
		while (++i < width)	
		{
			game->sdl->surface->data[i+j*width] = getSurroundingAverage(game, i, j); //game->gpu->cpuOutput[i+ j *width];

		}
	}
}
/*
*	Fucntion: render all pixels on the surface
*	Parameters: game, sdl
*	Return: none
*/
void 	ft_render(t_game* game)
{
	int		i;
	int		j;
	int width = game->sdl->surface->width;
	int height = game->sdl->surface->height;
	j = -1;
	ft_run_gpu(game->gpu);
	while (++j < height)
	{
		i = -1;
		while (++i < width)	
			game->sdl->surface->data[i + j * width] =  game->gpu->cpuOutput[i + j * width];
	}
	//ft_filter(game);
}

/*
*	Fucntion: Main loop
*		1. Clear the screen
*		2. Handle input
*		3. Render
*	!	4. surface_combine is redrawing only part of the screen, not used yet
*		5. Put surface to texture and then to on Screen
*			? don't use surfaces and use just textures for speed
*	Parameters: game, sdl
*	Return: none
*/

void ft_update(t_game *game)
{
	t_rectangle r = (t_rectangle){(t_point){0,0},(t_size){WIN_W, WIN_H}};
	clock_t current_ticks, delta_ticks;
	clock_t fps = 0;
	while(TRUE)
	{
		current_ticks = clock();
		ft_surface_clear(game->sdl->surface);
		ft_input(game->sdl, &ft_input_keys);

		(game->wsad[2] && game->gpu->samples > 15) ? game->gpu->samples -= 15 : 0;
		(game->wsad[3] && game->gpu->samples < 1000) ? game->gpu->samples += 15 : 0;

		if (game->init_render || game->wsad[0] || game->wsad[1] ||
			game->wsad[2] || game->wsad[3] || game->wsad[4] || game->wsad[5] ||
			game->wsad[6] || game->wsad[7] || game->wsad[8]) // 8 - is mouse TODO need other array
			{
				game->wsad[8] = 0;
				game->init_render = 0;
				ft_render(game);
				ft_surface_present(game->sdl, game->sdl->surface);
			}
	SDL_Delay(5);
	}
}


int	main(int argc, char **argv)
{
	// t_cl_info cl_info;
	// cl_init(&cl_info);
	//VECT_ADD(v, "hello");
	//printf("%s", (char *)v->data);
	game.sdl = malloc(sizeof(t_sdl));
	game.image = ft_surface_create(WIN_W, WIN_H);

	game.init_render = 1;
	game.origin = (t_vec3){0,0,5};
	game.gpu = (t_gpu *)malloc(sizeof(t_gpu));
	opencl_init(game.gpu, &game);
	ft_init_window(game.sdl, WIN_W, WIN_H);

	ft_update(&game);
	clReleaseMemObject(game.gpu->cl_bufferOut);
	release_gpu(game.gpu);

	ft_exit(NULL);
}