static void
test_cookie (Xcb.VoidCookie cookie, Xcb.Connection connection, string err_message)
{
    Xcb.GenericError? error = connection.request_check (cookie);
    if (error != null)
    {
        print ("ERROR: %s : %d\n", err_message , error.error_code);
        Posix.exit (-1);
    }
}

static Xcb.GContext
get_font_gc (Xcb.Connection connection, Xcb.Screen screen, Xcb.Window window, string font_name)
{
    /* get font */
    Xcb.Font       font        = Xcb.Font (connection);
    Xcb.VoidCookie font_cookie = font.open_checked (connection, font_name.to_utf8 ());

    test_cookie(font_cookie, connection, "can't open font");

    /* create graphics context */
    Xcb.GContext    gc            = Xcb.GContext (connection);
    int32           mask          = Xcb.GC.FOREGROUND | Xcb.GC.BACKGROUND | Xcb.GC.FONT;
    uint32[]        value_list    = { screen.black_pixel, screen.white_pixel, font };

    Xcb.VoidCookie gc_cookie = gc.create_checked (connection, window, mask, value_list );

    test_cookie (gc_cookie, connection, "can't create gc");


    /* close font */
    font_cookie = font.close_checked (connection);

    test_cookie(font_cookie, connection, "can't close font");

    return gc;
}

static void
draw_text (Xcb.Connection connection, Xcb.Screen screen, Xcb.Window window,
          int16 x1, int16 y1, string label )
{
    /* get graphics context */
    Xcb.GContext gc = get_font_gc (connection, screen, window, "7x13");

    /* draw the text */
    Xcb.VoidCookie text_cookie = window.image_text_8_checked (connection, gc,
                                                              x1, y1, label.to_utf8 ());

    test_cookie (text_cookie, connection, "can't paste text");


    /* free the gc */
    Xcb.VoidCookie gc_cookie = gc.free (connection);

    test_cookie(gc_cookie, connection, "can't free gc");
}

static int
main (string[] inArgs)
{
    /* get the connection */
    int screenNum;
    Xcb.Connection connection = new Xcb.Connection (null, out screenNum);
    if (connection == null)
    {
        print ("ERROR: can't connect to an X server\n");
        return -1;
    }

    /* get the current screen */
    unowned Xcb.Screen? screen = connection.roots[screenNum];
    if (screen == null)
    {
        print ("ERROR: can't get the current screen\n");
        return -1;
    }

    /* Create the window */
    Xcb.Window window = Xcb.Window (connection);

    uint32 mask = Xcb.Cw.BACK_PIXEL | Xcb.Cw.EVENT_MASK;
    uint32[] values = { screen.white_pixel,
                        Xcb.EventMask.KEY_RELEASE | Xcb.EventMask.BUTTON_PRESS |
                        Xcb.EventMask.EXPOSURE    | Xcb.EventMask.POINTER_MOTION };

    Xcb.VoidCookie window_cookie = window.create_checked (connection,
                                                          screen.root_depth,
                                                          screen.root,
                                                          20, 200,
                                                          300, 100,
                                                          0,
                                                          Xcb.WindowClass.INPUT_OUTPUT,
                                                          screen.root_visual,
                                                          mask, values);
    test_cookie (window_cookie, connection, "can't create window");

    Xcb.VoidCookie map_cookie = window.map_checked (connection);

    test_cookie(map_cookie, connection, "can't map window");

    connection.flush ();  // make sure window is drawn

    /* event loop */
    Xcb.GenericEvent event;
    while ((event = connection.wait_for_event ()) != null)
    {
        switch (event.response_type & ~0x80)
        {
            case Xcb.EventType.EXPOSE:
                draw_text (connection, screen, window, 10, 90 - 10, "Press ESC key to exit...");
                connection.flush ();
                break;

            case Xcb.EventType.KEY_RELEASE:
                unowned Xcb.KeyReleaseEvent? kr = (Xcb.KeyReleaseEvent?)event;

                switch (kr.detail)
                {
                    /* ESC */
                    case 9:
                        return 0;
                }
                break;
        }
    }

    return 0;
}
