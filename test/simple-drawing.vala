static int
main (string[] inArgs)
{
    /* geometric objects */
    Xcb.Point p1 = {10, 10};
    Xcb.Point p2 = {10, 20};
    Xcb.Point p3 = {20, 10};
    Xcb.Point p4 = {20, 20};
    Xcb.Point[] points = { p1, p2, p3, p4 };

    Xcb.Point pl1 = {50, 10};
    Xcb.Point pl2 = { 5, 20};     /* rest of points are relative */
    Xcb.Point pl3 = {25,-20};
    Xcb.Point pl4 = {10, 10};
    Xcb.Point polyline[4] = { pl1, pl2, pl3, pl4 };

    Xcb.Segment s1 = {100, 10, 140, 30};
    Xcb.Segment s2 = {110, 25, 130, 60};
    Xcb.Segment segments[2] = { s1, s2 };

    Xcb.Rectangle r1 = {10, 50, 40, 20};
    Xcb.Rectangle r2 = {80, 50, 10, 40};
    Xcb.Rectangle rectangles[2] = { r1, r2 };

    Xcb.Arc a1 = {10, 100, 60, 40, 0, 90 << 6};
    Xcb.Arc a2 = {90, 100, 55, 40, 0, 270 << 6};
    Xcb.Arc arcs[2] = { a1, a2 };

    /* Get the first screen */
    Xcb.Connection connection = new Xcb.Connection ();
    unowned Xcb.Screen screen = connection.roots[0];

    /* Create black (foreground) graphic context */
    Xcb.GContext foreground = Xcb.GContext (connection);
    uint32 mask = Xcb.GC.FOREGROUND | Xcb.GC.GRAPHICS_EXPOSURES;
    uint32 values[2] = { screen.black_pixel, 0 };

    foreground.create (connection, screen.root, mask, values);

    /* Create the window */
    Xcb.Window window = Xcb.Window (connection);
    mask = Xcb.Cw.BACK_PIXEL | Xcb.Cw.EVENT_MASK;
    values[0] = screen.white_pixel;
    values[1] = Xcb.EventMask.EXPOSURE;

    window.create (connection,                          /* Connection          */
                   Xcb.COPY_FROM_PARENT,                /* depth (same as root)*/
                   screen.root,                         /* parent window       */
                   0, 0,                                /* x, y                */
                   150, 150,                            /* width, height       */
                   10,                                  /* border_width        */
                   Xcb.WindowClass.INPUT_OUTPUT,        /* class               */
                   screen.root_visual,                  /* visual              */
                   mask, values);                       /* masks               */

    /* Map the window on the screen */
    window.map (connection);

    /* Make sure commands are sent before we pause so that the window gets shown */
    connection.flush ();

    /* draw primitives */
    Xcb.GenericEvent? event;
    while ((event = connection.wait_for_event ()) != null)
    {
        switch (event.response_type & ~0x80)
        {
            case Xcb.EventType.EXPOSE:
                /* We draw the points */
                window.poly_point (connection, Xcb.CoordMode.ORIGIN, foreground, points);

                /* We draw the polygonal line */
                window.poly_line (connection, Xcb.CoordMode.PREVIOUS, foreground, polyline);

                /* We draw the segements */
                window.poly_segment (connection, foreground, segments);

                /* draw the rectangles */
                window.poly_rectangle (connection, foreground, rectangles);

                /* draw the arcs */
                window.poly_arc (connection, foreground, arcs);

                /* flush the request */
                connection.flush ();

                break;
            default:
                /* Unknown event type, ignore it */
                break;
        }
    }

    return 0;
}
