void *malloc();
void *SDL_CreateWindow();
void *SDL_CreateRenderer();
int SDL_SetRenderDrawColor();
int SDL_RenderDrawPoint();
int SDL_RenderClear();
int SDL_RenderPresent();
int SDL_PollEvent();
int SDL_DestroyRenderer();
int SDL_DestroyWindow();
int SDL_Quit();
int SDL_Init();

void *win;
void *rnd;
int W;
int H;
int *col;

void plot(int x, int y) {
	int n, fx, fy, zx, zy, nx, ny;

	fx = (x - W/2)*4000 / W;
	fy = (y - H/2)*4000 / H;
	zx = fx;
	zy = fy;

	for (n=0; n<200; n++) {
		if (zx*zx + zy*zy > 4000000)
			break;
		nx = (zx*zx)/1000 - (zy*zy)/1000 + fx;
		ny = zx*zy/500 + fy;
		zx = nx;
		zy = ny;
	}
	n = col[n];
	SDL_SetRenderDrawColor(rnd, 100, n, n, 255);
	SDL_RenderDrawPoint(rnd, x, y);
	return;
}

int main() {
	int c, n, x, y, *ie;
	void *e;

	W = 800;
	H = 800;
	SDL_Init(32);
	win = SDL_CreateWindow("Mandelbrot MiniC", 0, 0, W, H, 0);
	rnd = SDL_CreateRenderer(win, -1, 0);
	e = malloc(56);
	ie = e;
	col = malloc(201 * sizeof (int));
	c = 20;
	for (n=0; n<200; n++) {
		col[n] = c;
		c = c + (255-c)/8;
	}
	col[n] = 30;

	SDL_RenderClear(rnd);
	for (x=0; x<W; x++)
		for (y=0; y<H; y++)
			plot(x, y);
	SDL_RenderPresent(rnd);

	for (;;) {
		if (SDL_PollEvent(e)) {
			if (ie[0] == 769)
				break;
		}
	}

	SDL_DestroyRenderer(rnd);
	SDL_DestroyWindow(win);
	SDL_Quit();
}
