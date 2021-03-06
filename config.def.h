/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

/* -b  option; if 0, dmenu appears at bottom */
static int topbar = 1;
/* -c option; centers dmenu on screen */
static int centered = 0;
/* minimum width when centered */
static int min_width = 250;
/* -fn option overrides fonts[0]; default X11 font or font set */
static char font[] = "DejaVuSansMono Nerd Font:pixelsize=16:antialias=true:autohint=true";
static char fontfallback[] = "Source-Code-Pro:pixelsize=14:antialias=true:autohint=true";
static char fontemoji[] = "JoyPixels:pixelsize=14:antialias=true:autohint=true";
static const char *fonts[] = {
	font,
    fontfallback,
    fontemoji
};
static const unsigned int alpha = 0xe6;
/* -p  option; prompt to the left of input field */
static const char *prompt = "run »";
static const char *symbol_1 = "«";
static const char *symbol_2 = "»";

static char foreground[]              = "#cccccc";
static char background[]              = "#000000";
static char selforeground[]           = "#cccccc";
static char selbackground[]           = "#4185d7";
static char selhighlightforeground[]  = "#ffffff";
static char selhighlightbackground[]  = "#4185d7";
static char normhighlightforeground[] = "#4185d7";
static char normhighlightbackground[] = "#000000";
static char outforeground[]           = "#000000";
static char outbackground[]           = "#1f5393";
static char *colors[SchemeLast][2] = {
	/*                    foreground, background */
	[SchemeNorm]          = { foreground, background },
	[SchemeSel]           = { selforeground, selbackground },
	[SchemeSelHighlight]  = { selhighlightforeground, selhighlightbackground },
	[SchemeNormHighlight] = { normhighlightforeground, normhighlightbackground },
	[SchemeOut]           = { outforeground, outbackground },
};

static const unsigned int alphas[SchemeLast][2] = {
    /*                    foreground, background */
    [SchemeNorm]          = { OPAQUE, alpha },
    [SchemeSel]           = { OPAQUE, OPAQUE },
    [SchemeSelHighlight]  = { OPAQUE, OPAQUE },
    [SchemeNormHighlight] = { OPAQUE, alpha },
    [SchemeOut]           = { OPAQUE, OPAQUE },
};

/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines = 0;
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

/*
 * Xresources preferences to load at startup
 */
ResourcePref resources[] = {
	{ "font",                    STRING, &font },
	{ "fontfallback",            STRING, &fontfallback },
	{ "fontemoji",               STRING, &fontemoji },
	{ "foreground",              STRING, &foreground },
	{ "background",              STRING, &background },
	{ "selforeground",           STRING, &selforeground },
	{ "selbackground",           STRING, &selbackground },
	{ "selhighlightforeground",  STRING, &selhighlightforeground },
	{ "selhighlightbackground",  STRING, &selhighlightbackground },
	{ "normhighlightforeground", STRING, &normhighlightforeground },
	{ "normhighlightbackground", STRING, &normhighlightbackground },
	{ "outforeground",           STRING, &outforeground },
	{ "outbackground",           STRING, &outbackground },
};
