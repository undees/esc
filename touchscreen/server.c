/* Loosely based on the chat.c example that ships with Mongoose. */

#include <stdio.h>
#include <stdlib.h>

#include "mongoose.h"

static const char *reply_start =
    "HTTP/1.1 200 OK\r\n"
    "Cache: no-cache\r\n"
    "Content-Type: text/html\r\n"
    "\r\n";

static void find_window(struct mg_connection *conn,
                        const struct mg_request_info *request_info)
{
    char title      [200];
    char windowClass[200];

    int windowClassResult = mg_get_qsvar(request_info, "windowClass", windowClass, sizeof(windowClass));
    int titleResult       = mg_get_qsvar(request_info, "title",       title,       sizeof(title));

    unsigned long result = 12345;
/*     unsigned long result = FindWindowA( */
/*         0 <= windowClassResult ? NULL : windowClass, */
/*         0 <= titleResult       ? NULL : title); */

    mg_printf(conn, "%s%d", reply_start, result);
}

static int process_request(struct mg_connection *conn,
                           const struct mg_request_info *request_info)
{
    if (strcmp(request_info->uri, "/FindWindow") == 0)
    {
        find_window(conn, request_info);
    }
    else
    {
        return 0;
    }

    return 1;
}

int main(int argc, char *argv[])
{
    struct mg_context *ctx = mg_start();

    mg_set_option(ctx, "ports", "8081");
    mg_set_callback(ctx, MG_EVENT_NEW_REQUEST, &process_request);

    getchar();

    mg_stop(ctx);

    return EXIT_SUCCESS;
}
