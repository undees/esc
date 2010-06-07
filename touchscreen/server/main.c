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
    wchar_t *title = get_varw(conn, "title");

    HWND hwnd = FindWindowW(windowClass, title);

    mg_printf(conn,
        "HTTP/1.1 200 OK\r\n\
Content-Type: text/html\r\n\r\n%d",
        hwnd);

    free(title);
}


static void click_control(
    struct mg_connection *conn,
    const struct mg_request_info *request_info,
    void *user_data)
{
    int succeeded = 0;
    char *parent_s  = mg_get_var(conn, "parent");
    char *control_s = mg_get_var(conn, "control");

    if (parent_s  != NULL &&
        control_s != NULL)
    {
        HWND parent  = (HWND)atol(parent_s);
        int  control =       atoi(control_s);
        HWND hwnd    = GetDlgItem(parent, control);
        RECT rect    = {0};

        if (GetWindowRect(hwnd, &rect))
        {
            int x = (rect.left + rect.right)  / 2;
            int y = (rect.top  + rect.bottom) / 2;

            HDC dc   = GetDC(HWND_DESKTOP);
            int xRes = GetDeviceCaps(dc, HORZRES);
            int yRes = GetDeviceCaps(dc, VERTRES);
            ReleaseDC(HWND_DESKTOP, dc);

            x = x * 65535 / xRes;
            y = y * 65535 / yRes;

            mouse_event(MOUSEEVENTF_LEFTDOWN | MOUSEEVENTF_ABSOLUTE, x, y, 0, 0);
            mouse_event(MOUSEEVENTF_LEFTUP   | MOUSEEVENTF_ABSOLUTE, x, y, 0, 0);

            succeeded = 1;
        }
    }

    mg_printf(conn,
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n%d",
        succeeded);

    mg_free(parent_s);
    mg_free(control_s);
}


static void is_control_enabled(
    struct mg_connection *conn,
    const struct mg_request_info *request_info,
    void *user_data)
{
    int result = -1;

    char *parent_s  = mg_get_var(conn, "parent");
    char *control_s = mg_get_var(conn, "control");

    if (parent_s  != NULL &&
        control_s != NULL)
    {
        HWND parent  = (HWND)atol(parent_s);
        int  control =       atoi(control_s);
        HWND hwnd    = GetDlgItem(parent, control);

        if (hwnd)
        {
            LONG style = GetWindowLong(hwnd, GWL_STYLE);
            result = (style & WS_DISABLED) ? 0 : 1;
        }
    }

    mg_printf(conn,
        "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n%d",
        result);

    mg_free(parent_s);
    mg_free(control_s);
}


int WinMainCRTStartup()
{
    struct mg_context *ctx = mg_start();
    mg_set_option(ctx, "ports", "8080");

    mg_set_uri_callback(ctx, "/",                 &show_index,         0);
    mg_set_uri_callback(ctx, "/FindWindow",       &find_window,        0);
    mg_set_uri_callback(ctx, "/ClickControl",     &click_control,      0);
    mg_set_uri_callback(ctx, "/IsControlEnabled", &is_control_enabled, 0);

    getchar();
    mg_stop(ctx);

    return 0;
}
