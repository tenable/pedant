#include <glib.h>

#include "cfg.h"
#include "log.h"

static gchar *opt_d = NULL;
static gint opt_v = 0;

static gboolean verbosity(const gchar *option_name, const gchar *value, gpointer data, GError **error)
{
	opt_v = (opt_v < 2) ? opt_v + 1 : opt_v;

	return TRUE;
}

static GOptionEntry entries[] =
{
	{"database", 'd', 0, G_OPTION_ARG_FILENAME, &opt_d, "Specify the database to be used, ~/.pedant/database.sqlite by default", NULL},
	{"verbose", 'v', G_OPTION_FLAG_NO_ARG, G_OPTION_ARG_CALLBACK, verbosity, "Be more verbose, can be used multiple times", NULL},
	{NULL}
};

void cli_run(gint argc, gchar **argv)
{
	GOptionContext *ctx = g_option_context_new("[dir|file|treeish] ...");
	g_option_context_add_main_entries(ctx, entries, NULL);
	g_option_context_set_help_enabled(ctx, TRUE);

	GError *err = NULL;
	if (!g_option_context_parse(ctx, &argc, &argv, &err))
	{
		g_critical("Option parsing failed: %s.", err->message);
		return;
	}

	g_option_context_free(ctx);

	cfg_set_str("database", opt_d);
	cfg_set_int("verbosity", opt_v);

	GLogLevelFlags lvl = 0;
	switch (opt_v)
	{
	case 1:
		lvl = G_LOG_LEVEL_WARNING;
		break;
	case 2:
		lvl = G_LOG_LEVEL_INFO;
		break;
	case 3:
		lvl = G_LOG_LEVEL_DEBUG;
		break;
	}

	if (lvl > 0)
		log_set_verbosity(lvl);
}
