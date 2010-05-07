/* implements http://10.0.0.100/FindWindow?title=Something */
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
