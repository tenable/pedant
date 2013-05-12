#include <glib.h>
#include <stdio.h>

static void log_to_db(const gchar *log_domain, GLogLevelFlags log_level, const gchar *message, gpointer user_data)
{
}

void log_to_ui(const gchar *log_domain, GLogLevelFlags log_level, const gchar *message, gpointer user_data)
{
	fputs(message, stderr);
}

static gboolean verbose(const gchar *option_name, const gchar *value, gpointer data, GError **error)
{
	static gint verbosity = 0;

	switch (++verbosity)
	{
	case 1:
		g_debug("Changing message level to 'critical'.\n");
		g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, log_to_ui, NULL);
		break;
	case 2:
		g_debug("Changing message level to 'warning'.\n");
		g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_WARNING, log_to_ui, NULL);
		break;
	case 3:
		g_debug("Changing message level to 'debug'.\n");
		g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, log_to_ui, NULL);
		break;
	default:
		g_debug("Verbosity level is already at maximum.\n");
		verbosity--;
		break;
	}

	return TRUE;
}

static GOptionEntry entries[] =
{
	{"verbose", 'v', G_OPTION_FLAG_NO_ARG, G_OPTION_ARG_CALLBACK, verbose, "Be more verbose, can be used multiple times", NULL},
	{NULL}
};

int main(int argc, char **argv)
{
	g_debug("Setting logging to highest level for database.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_MASK, log_to_db, NULL);

	g_debug("Setting logging to lowest level for UI.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_ERROR, log_to_ui, NULL);

	GOptionContext *ctx = g_option_context_new("[dir|file|treeish] ...");
	g_option_context_add_main_entries(ctx, entries, NULL);
	g_option_context_set_help_enabled(ctx, TRUE);

	GError *err = NULL;
	if (!g_option_context_parse(ctx, &argc, &argv, &err))
	{
		g_error("option parsing failed: %s", err->message);
		return 1;
	}

	g_option_context_free(ctx);

	return 0;
}
