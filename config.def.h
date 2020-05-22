/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom */
static int centered = 0;                    /* -c option; centers dmenu on screen */
static int min_width = 250;                 /* minimum width when centered */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"DejaVu Sans Mono:pixelsize=16:antialias=true:autohint=true",
	"JoyPixels:pixelsize=14:antialias=true:autohint=true"
};
static const unsigned int bgalpha = 0xe5;
static const unsigned int fgalpha = OPAQUE;
static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
static const char *symbol_1 = "«";
static const char *symbol_2 = "»";
static const char *colors[SchemeLast][2] = {
	/*                fg         bg       */
	[SchemeNorm] = { "#cccccc", "#000000" },
	[SchemeSel] = { "#cccccc", "#4185d7" },
	[SchemeSelHighlight] = { "#ffffff", "#4185d7" },
	[SchemeNormHighlight] = { "#4185d7", "#000000" },
	[SchemeOut] = { "#000000", "#009698" },
};
static const unsigned int alphas[SchemeLast][2] = {
	/*               fgalpha  bgalpha */
	[SchemeNorm] = { fgalpha, bgalpha },
	[SchemeSel] = { fgalpha, bgalpha },
	[SchemeSelHighlight] = { fgalpha, bgalpha },
	[SchemeNormHighlight] = { fgalpha, bgalpha },
	[SchemeOut] = { fgalpha, bgalpha },
};

/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;
static unsigned int lineheight = 26;         /* -h option; minimum height of a menu line */

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";

/* Size of the window border */
static unsigned int border_width = 0;
