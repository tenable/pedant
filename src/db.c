#include <errno.h>
#include <sqlite3.h>

#include "cfg.h"
#include "db.h"
#include "log.h"

static sqlite3 *db = NULL;

gboolean db_new(void)
{
	if (db != NULL)
		return TRUE;

	const gchar *path = cfg_get_str("database");
	if (path == NULL)
	{
		logl(CRITICAL, "Failed to retrieve database path from config.");
		return FALSE;
	}

	gchar *dir = g_path_get_dirname(path);
	if (dir == NULL)
	{
		logf(CRITICAL, "Failed to parse directory of '%s'.", path);
		return 1;
	}

	gint rc = g_mkdir_with_parents(dir, 0700);
	switch (rc)
	{
	case 0:
		logf(INFO, "Didn't create directory '%s' because it already exists.", dir);
		break;
	case 1:
		logf(WARNING, "Created directory '%s' to store the database.", dir);
		break;
	default:
		logf(CRITICAL, "Failed to create directory '%s': %s.", dir, g_strerror(errno));
		return 1;
	}
	g_free(dir);

	rc = sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
	if (rc != SQLITE_OK)
	{
		logf(CRITICAL, "Failed to open database '%s': %s.", path, sqlite3_errstr(rc));
		sqlite3_close(db);
		return FALSE;
	}

	rc = sqlite3_extended_result_codes(db, TRUE);
	if (rc != SQLITE_OK)
	{
		logf(CRITICAL, "Failed to enable extended result codes: %s.", sqlite3_errstr(rc));
		sqlite3_close(db);
		return FALSE;
	}

	return TRUE;
}

void db_del(void)
{
	sqlite3_close(db);
}

gboolean db_qry(const gchar *sql)
{
	gchar *errmsg = NULL;
	gint rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
	if (rc != SQLITE_OK)
	{
		logf(DEBUG, "Failed to execute SQL query '%s': %s.", sql, errmsg);
		sqlite3_free(errmsg);
		return FALSE;
	}

	return TRUE;
}

gboolean db_qry_args(const gchar *sql, ...)
{
	sqlite3_stmt *stmt = NULL;

	gint rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
	if (rc != SQLITE_OK)
		logf(ERROR, "Failed to prepare SQL statement '%s': %s.", sql, sqlite3_errstr(rc));

	gint params = sqlite3_bind_parameter_count(stmt);
	if (params > 0)
	{
		va_list args;
		va_start(args, sql);

		gint i = 0;
		while (i <= params)
		{
			 const gchar *name = sqlite3_bind_parameter_name(stmt, i);
			 if (name == NULL)
				 logf(ERROR, "Parameter %d in SQL statement '%s' does not have a name.", i, sql);

			 glong len = g_utf8_strlen(name, -1);
			 if (len < 3)
				 logf(ERROR, "Parameter %d, named '%s', is of length %ld but must be at least 3.", i, name, len);

			 const gchar *name_0 = g_utf8_offset_to_pointer(name, 0);
			 if (g_utf8_get_char(name_0) != ':')
				 logf(ERROR, "Parameter '%s' does not have a leading colon.", name);

			 const gchar *name_1 = g_utf8_offset_to_pointer(name, 1);
			 if (!g_unichar_islower(g_utf8_get_char(name_1)))
				 logf(ERROR, "Parameter '%s' does not have a first letter, indicating its type, that is lowercase.", name);
			 
			 const gchar *name_2 = g_utf8_offset_to_pointer(name, 2);
			 if (!g_unichar_isupper(g_utf8_get_char(name_2)))
				 logf(ERROR, "Parameter '%s' does not have a second letter, starting its name, that is uppercase.", name);

			 gint used = 1;
			 switch (*name_1)
			 {
			 case 'b':
				 if (i + 1 > params)
					 logf(ERROR, "Failed to bind parameter '%s' in SQL statement '%s': missing length of BLOB.", name, sql);
				 rc = sqlite3_bind_blob(stmt, i, va_arg(args, gpointer), va_arg(args, gint), NULL);
				 used = 2;
				 break;
			 case 'd':
				 rc = sqlite3_bind_double(stmt, i, va_arg(args, gdouble));
				 break;
			 case 'i':
				 rc = sqlite3_bind_int(stmt, i, va_arg(args, gint));
				 break;
			 case 'l':
				 rc = sqlite3_bind_int64(stmt, i, va_arg(args, glong));
				 break;
			 case 'n':
				 rc = sqlite3_bind_null(stmt, i);
				 used = 0;
				 break;
			 case 't':
				 rc = sqlite3_bind_text(stmt, i, va_arg(args, gchar *), -1, NULL);
				 break;
			 case 'v':
				 rc = sqlite3_bind_value(stmt, i, va_arg(args, sqlite3_value *));
				 break;
			 case 'z':
				 rc = sqlite3_bind_zeroblob(stmt, i, va_arg(args, gint));
				 break;
			 default:
				 logf(ERROR, "Parameter '%s' has unknown type '%c'.", name, *name_1);
			 }

			 if (rc != SQLITE_OK)
				 logf(ERROR, "Failed to bind parameter '%s' in SQL statement '%s': %s.", name, sql, sqlite3_errstr(rc));

			 i += used;
		}

		va_end(args);
	}

	rc = sqlite3_step(stmt);
	if (rc != SQLITE_DONE)
	{
		logf(CRITICAL, "Failed to execute prepared logging statement: %s.", sqlite3_errstr(rc));
		return FALSE;
	}

	rc = sqlite3_finalize(stmt);
	if (rc != SQLITE_OK)
	{
		logf(CRITICAL, "Failed to finalize prepared logging statement: %s.", sqlite3_errstr(rc));
		return FALSE;
	}

	return TRUE;
}
