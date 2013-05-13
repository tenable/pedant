#ifndef _CFG_H
#define _CFG_H

#include <glib.h>

gboolean cfg_new(void);
void cfg_del(void);

gboolean cfg_has_key(const gchar *key);

int cfg_get_int(const gchar *key);
const gchar *cfg_get_str(const gchar *key);

gboolean cfg_set_int(const gchar *key, gint val);
gboolean cfg_set_str(const gchar *key, const gchar *val);

#endif
