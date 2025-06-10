#define DECLSPEC
#define SDLCALL
#define Uint32 unsigned int
#define Uint8 unsigned char

#define SDL_Window void
#define SDL_Renderer void
#define SDL_Event void
#define SDL_Texture void


extern DECLSPEC SDL_Window * SDLCALL SDL_CreateWindow(const char *title, int x, int y, int w, int h, Uint32 flags);

extern DECLSPEC SDL_Renderer * SDLCALL SDL_CreateRenderer(SDL_Window * window, int index, Uint32 flags);

extern DECLSPEC int SDLCALL SDL_SetRenderDrawColor(SDL_Renderer * renderer, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

extern DECLSPEC int SDLCALL SDL_RenderDrawPoint(SDL_Renderer * renderer, int x, int y);

extern DECLSPEC int SDLCALL SDL_RenderClear(SDL_Renderer * renderer);

extern DECLSPEC void SDLCALL SDL_RenderPresent(SDL_Renderer * renderer);

extern DECLSPEC int SDLCALL SDL_PollEvent(SDL_Event * event);

extern DECLSPEC void SDLCALL SDL_DestroyTexture(SDL_Texture * texture);

extern DECLSPEC void SDLCALL SDL_DestroyRenderer(SDL_Renderer * renderer);

extern DECLSPEC void SDLCALL SDL_DestroyWindow(SDL_Window * window);

extern DECLSPEC void SDLCALL SDL_Quit(void);

extern DECLSPEC int SDLCALL SDL_Init(Uint32 flags);

