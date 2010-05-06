#include <stdio.h>
#include <windows.h>

#include "mongoose.h"


static void show_index(
    struct mg_connection *conn,
    const struct mg_request_info *request_info,
    void *user_data)
{
    mg_printf(conn, "%s",
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"
        "Hello world!");
}


static wchar_t* get_varw(
    struct mg_connection *conn,
    const char *name)
{
    char    *value  = mg_get_var(conn, name);
    wchar_t *valuew = NULL;

    if (value)
    {
        int chars = mbstowcs(NULL, value, 0) + 1;
        valuew    = malloc(chars * sizeof(wchar_t));
        mbstowcs(valuew, value, chars);
        mg_free(value);
    }

    return valuew;
}

static void find_window(
    struct mg_connection *conn,
    const struct mg_request_info *request_info,
    void *user_data)
{
    wchar_t *title       = get_varw(conn, "title");
    wchar_t *windowClass = get_varw(conn, "windowClass");

    HWND hwnd = FindWindowW(windowClass, title);

    mg_printf(conn,
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n%d",
        hwnd);

    free(title);
    free(windowClass);
}


int WinMainCRTStartup()
{
    struct mg_context *ctx = mg_start();
    mg_set_option(ctx, "ports", "8080");

    mg_set_uri_callback(ctx, "/",           &show_index,  0);
    mg_set_uri_callback(ctx, "/FindWindow", &find_window, 0);

    getchar();
    mg_stop(ctx);

    return 0;
}