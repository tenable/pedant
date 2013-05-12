#include <errno.h>
#include <glib.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static GHashTable *config = NULL;
static gchar *opt_d = NULL;
static gint opt_v = 0;

static sqlite3 *db = NULL;

static void query(const gchar *sql)
{
	gchar *errmsg = NULL;
	gint rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to execute SQL query '%s': %s", sql, errmsg);
		sqlite3_free(errmsg);
		sqlite3_close(db);
		exit(1);
	}
}

static void log_to_db(const gchar *log_domain, GLogLevelFlags log_level, const gchar *message, gpointer user_data)
{
	sqlite3_stmt *stmt = NULL;

	const gchar *sql = "INSERT INTO log (level, message) VALUES (?, ?);";
	gint rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to prepare SQL statement '%s': %s.", sql, sqlite3_errstr(rc));
		sqlite3_close(db);
		exit(1);
	}

	rc = sqlite3_bind_int(stmt, 1, log_level & G_LOG_LEVEL_MASK);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to bind log level to prepared statement: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		exit(1);
	}

	rc = sqlite3_bind_text(stmt, 2, message, -1, SQLITE_STATIC);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to bind log message to prepared statement: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		exit(1);
	}

	rc = sqlite3_step(stmt);
	if (rc != SQLITE_DONE)
	{
		g_critical("Failed to execute prepared logging statement: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		exit(1);
	}

	rc = sqlite3_finalize(stmt);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to finalize prepared logging statement: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		exit(1);
	}
}

void log_to_ui(const gchar *log_domain, GLogLevelFlags log_level, const gchar *message, gpointer user_data)
{
	fprintf(stderr, "%s\n", message);
}

static gboolean verbose(const gchar *option_name, const gchar *value, gpointer data, GError **error)
{
	opt_v = (opt_v < 2) ? opt_v + 1 : opt_v;

	return TRUE;
}

static GOptionEntry entries[] =
{
	{"database", 'd', 0, G_OPTION_ARG_FILENAME, &opt_d, "Specify the database to be used, ~/.pedant/database.sqlite by default", NULL},
	{"verbose", 'v', G_OPTION_FLAG_NO_ARG, G_OPTION_ARG_CALLBACK, verbose, "Be more verbose, can be used multiple times", NULL},
	{NULL}
};

int main(gint argc, gchar **argv)
{
	g_debug("Setting logging to lowest level for the UI.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, log_to_ui, NULL);

	config = g_hash_table_new(g_str_hash, g_str_equal);
	if (config == NULL)
	{
		g_critical("Failed to create the config hashtable.");
		return 1;
	}

	GOptionContext *ctx = g_option_context_new("[dir|file|treeish] ...");
	g_option_context_add_main_entries(ctx, entries, NULL);
	g_option_context_set_help_enabled(ctx, TRUE);

	GError *err = NULL;
	if (!g_option_context_parse(ctx, &argc, &argv, &err))
	{
		g_critical("Option parsing failed: %s.", err->message);
		return 1;
	}

	g_option_context_free(ctx);

	g_hash_table_insert(config, "database", &opt_d);
	g_hash_table_insert(config, "verbosity", &opt_v);

	gchar *loglevel_name = NULL;
	gint loglevel_enum = 0;
	switch (opt_v)
	{
	case 1:
		loglevel_name = "warning";
		loglevel_enum = G_LOG_LEVEL_WARNING;
		break;
	case 2:
		loglevel_name = "debug";
		loglevel_enum = G_LOG_LEVEL_DEBUG;
		break;
	}

	if (loglevel_name != NULL)
	{
		g_debug("Changing message level to '%s'.", loglevel_name);
		g_log_set_handler(G_LOG_DOMAIN, loglevel_enum, log_to_ui, NULL);
	}

	if (opt_d == NULL)
	{
		const gchar *home = g_get_home_dir();
		if (home == NULL)
		{
			g_critical("Failed to determine the current user's home directory.");
			return 1;
		}
		opt_d = g_strdup_printf("%s/.pedant/database.sqlite", home);
	}

	gchar *dir = g_path_get_dirname(opt_d);
	if (dir == NULL)
	{
		g_critical("Failed to parse directory of '%s'.", opt_d);
		return 1;
	}

	gint rc = g_mkdir_with_parents(dir, 0700);
	switch (rc)
	{
	case 0:
		g_debug("Didn't create directory '%s' because it already exists.", dir);
		break;
	case 1:
		g_warning("Created directory '%s' to store the database.", dir);
		break;
	default:
		g_critical("Failed to create directory '%s': %s.", dir, g_strerror(errno));
		return 1;
	}
	g_free(dir);

	rc = sqlite3_open_v2(opt_d, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, NULL);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to open database '%s': %s.", opt_d, sqlite3_errstr(rc));
		sqlite3_close(db);
		return 1;
	}

	rc = sqlite3_extended_result_codes(db, TRUE);
	if (rc != SQLITE_OK)
	{
		g_critical("Failed to enable extended result codes: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		return 1;
	}

	query("CREATE TABLE IF NOT EXISTS log (occurred TIMESTAMP DEFAULT CURRENT_TIMESTAMP, level INTEGER, message TEXT);");
	query("DELETE FROM log;");

	g_debug("Setting logging to highest level for database.");
	g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_MASK, log_to_db, NULL);

	g_debug("Starting session.");
	g_debug("Finished session.");

	g_hash_table_destroy(config);

	return 0;
}
