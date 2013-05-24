#include "cfg.h"
#include "log.h"

static GHashTable *cfg = NULL;

gboolean cfg_new(void)
{
	cfg = g_hash_table_new_full(g_str_hash, g_str_equal, g_free, g_free);
	if (cfg == NULL)
	{
		logl(CRITICAL, "Failed to create the config hashtable.");
		return FALSE;
	}

	const gchar *home = g_get_home_dir();
	if (home == NULL)
	{
		logl(CRITICAL, "Failed to determine the current user's home directory.");
		g_hash_table_destroy(cfg);
		return FALSE;
	}

	gchar *database = g_strdup_printf("%s/.pedant/database.sqlite", home);
	if (database == NULL)
	{
		logl(CRITICAL, "Failed to create the default path to the database.");
		g_hash_table_destroy(cfg);
		return FALSE;
	}

	if (!cfg_set_str("database", database))
	{
		logl(CRITICAL, "Failed to set the default path to the database in the config.");
		g_hash_table_destroy(cfg);
		return FALSE;
	}

	g_free(database);

	if (!cfg_set_int("verbosity", 0))
	{
		logl(CRITICAL, "Failed to add the default verbosity in the config.");
		g_hash_table_destroy(cfg);
		return FALSE;
	}

	return TRUE;
}

void cfg_del(void)
{
	if (cfg == NULL)
		logl(ERROR, "Attempted to delete non-existent config.");

	g_hash_table_destroy(cfg);
}

gboolean cfg_has_key(const gchar *key)
{
	if (key == NULL)
		logl(ERROR, "Attempted to query existence of NULL key.");

	return g_hash_table_contains(cfg, key);
}

int cfg_get_int(const gchar *key)
{
	if (key == NULL)
		logl(ERROR, "Attempted to query existence of NULL key.");

	gpointer val = NULL;
	if (!g_hash_table_lookup_extended(cfg, key, NULL, &val))
		logf(ERROR, "Requested non-existent key '%s'.", key);

	return *((gint *) val);
}

const gchar *cfg_get_str(const gchar *key)
{
	if (key == NULL)
		logl(ERROR, "Attempted to query existence of NULL key.");

	gpointer val = NULL;
	if (!g_hash_table_lookup_extended(cfg, key, NULL, &val))
		logf(ERROR, "Requested non-existent key '%s'.", key);

	return val;
}

gboolean cfg_set_int(const gchar *key, gint val)
{
	gchar *key_copy = g_strdup(key);
	if (key_copy == NULL)
	{
		logl(CRITICAL, "Failed to create a copy of a key to add to the config.");
		return FALSE;
	}

	gint *val_copy = g_malloc(sizeof(gint));
	if (val_copy == NULL)
	{
		logl(CRITICAL, "Failed to create a copy of an integer value to add to the config.");
		return FALSE;
	}
	*val_copy = val;

	g_hash_table_replace(cfg, key_copy, val_copy);
	logf(DEBUG, "Set config key '%s' to integer value '%d'.", key, val);

	return TRUE;
}

gboolean cfg_set_str(const gchar *key, const gchar *val)
{
	if (val == NULL)
		logl(ERROR, "Keys with NULL values are not permitted in the config.");

	gchar *key_copy = g_strdup(key);
	if (key_copy == NULL)
	{
		g_critical("Failed to create a copy of a key to add to the config.");
		return FALSE;
	}

	gchar *val_copy = g_strdup(val);
	if (val_copy == NULL)
	{
		g_critical("Failed to create a copy of an integer value to add to the config.");
		return FALSE;
	}

	g_hash_table_replace(cfg, key_copy, val_copy);
	logf(DEBUG, "Set config key '%s' to string value '%s'.", key, val);

	return TRUE;
}
