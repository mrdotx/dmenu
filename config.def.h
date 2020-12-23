/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom */
static int centered = 0;                    /* -c option; centers dmenu on screen */
static int min_width = 250;                 /* minimum width when centered */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
    "DejaVuSansMono Nerd Font:pixelsize=16:antialias=true:autohint=true",
    "Source-Code-Pro:pixelsize=14:antialias=true:autohint=true",
    "JoyPixels:pixelsize=14:antialias=true:autohint=true"
};
static const unsigned int bgalpha = 0xe6;
static const unsigned int fgalpha = OPAQUE;
static const char *prompt      = "run »";      /* -p  option; prompt to the left of input field */
static const char *symbol_1 = "«";
static const char *symbol_2 = "»";
static const char *colors[SchemeLast][2] = {
    /*                fg         bg       */
    [SchemeNorm] = { "#cccccc", "#000000" },
    [SchemeSel] = { "#cccccc", "#4185d7" },
    [SchemeSelHighlight] = { "#ffffff", "#4185d7" },
    [SchemeNormHighlight] = { "#4185d7", "#000000" },
    [SchemeOut] = { "#000000", "#1f5393" },
};
static const unsigned int alphas[SchemeLast][2] = {
    /*                fgalpha    bgalphga    */
    [SchemeNorm] = { fgalpha, bgalpha },
    [SchemeSel] = { fgalpha, fgalpha },
    [SchemeSelHighlight] = { fgalpha, fgalpha },
    [SchemeNormHighlight] = { fgalpha, bgalpha },
    [SchemeOut] = { fgalpha, fgalpha },
};

/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;
/* -h option; minimum height of a menu line */
static unsigned int lineheight = 26;
static unsigned int min_lineheight = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";

/* Size of the window border */
static unsigned int border_width = 0;
