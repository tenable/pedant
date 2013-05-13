#ifndef _LOG_H
#define _LOG_H

#define logl(lvl, lit) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_ ## lvl, (lit))
#define logf(lvl, fmt, ...) g_log(G_LOG_DOMAIN, G_LOG_LEVEL_ ## lvl, (fmt), __VA_ARGS__)

#endif
