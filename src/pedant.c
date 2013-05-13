#include <errno.h>
#include <glib.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "cfg.h"
#include "cli.h"
#include "db.h"
#include "log.h"

int main(gint argc, gchar **argv)
{
	g_debug("Starting session.");
	g_debug("Finished session.");

	return 0;
}
