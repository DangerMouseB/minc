// https://www.google.com/search?q=how+to+install+SDL+macos&sxsrf=APwXEddKJiENodQCTs9oedChir7TE_UDww%3A1684782531568&ei=w71rZIKvIquZhbIPi9WkuA8&ved=0ahUKEwjCnMWC0In_AhWrTEEAHYsqCfcQ4dUDCA8&uact=5&oq=how+to+install+SDL+macos&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQAzIICAAQFhAeEA8yCAgAEIoFEIYDMggIABCKBRCGAzIICAAQigUQhgM6BwgjELADECc6CggAEEcQ1gQQsAM6CggAEIoFELADEEM6CggAEIAEEBQQhwI6BQgAEIAEOgYIABAWEB46CggAEBYQHhAPEAo6CAgAEAgQHhANSgQIQRgAUK8DWOUVYN0XaAFwAXgAgAFPiAG9A5IBATaYAQCgAQHIAQrAAQE&sclient=gws-wiz-serp#kpvalbx=_zL1rZPOICJSZgQbo2ISYCA_34
// https://libsdl.org/

// cc -o mandel mandel.s -F/Library/Frameworks -framework SDL2   << to link

#include <stdlib.h>
#include <SDL2/SDL.h>

void *rnd;
int W, H, *col;

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
    int c, n, x, y, *ie;  void *e, *win;
    W = 800;
    H = 800;
    SDL_Init(32);
    win = SDL_CreateWindow("Mandelbrot", 0, 0, W, H, 0);
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

    while (1) {
//    for (;;) { nyi
        if (SDL_PollEvent(e)) {
            if (ie[0] == 769)
                break;
        }
    }

    SDL_DestroyRenderer(rnd);
    SDL_DestroyWindow(win);
    SDL_Quit();
}
