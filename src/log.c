#include <glib.h>
#include <stdio.h>

#include "db.h"
#include "log.h"

static void log_to_ui(const gchar *domain, GLogLevelFlags lvl, const gchar *msg, gpointer unused)
{
	FILE *fp = (lvl & G_LOG_LEVEL_MESSAGE) ? stdout : stderr;

	fprintf(fp, "%s\n", msg);
}

static void log_to_db(const gchar *domain, GLogLevelFlags lvl, const gchar *msg, gpointer unused)
{
	const gchar *sql = "INSERT INTO log (:iLevel, :tMessage) VALUES (?, ?);";
	if (!db_qry_args(sql, lvl, msg))
	{
		gchar *error = g_strdup_printf("Failed to log message '%s' to the database.", msg);
		log_to_ui(domain, G_LOG_LEVEL_CRITICAL, error, NULL);
		g_free(error);
	}
}

gboolean log_new(void)
{
	logl(DEBUG, "Setting logging to lowest level for the UI.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, log_to_ui, NULL);

	logl(DEBUG, "Setting logging to highest level for database.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_MASK, log_to_db, NULL);

	return TRUE;
}
