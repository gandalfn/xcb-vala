static int
main (string[] inArgs)
{
    /* Get the first screen */
    Xcb.Connection connection = new Xcb.Connection ();
    unowned Xcb.Screen screen = connection.roots[0];

    /* Create the window */
    Xcb.Window window = Xcb.Window (connection);
    window.create (connection,                          /* Connection          */
                   Xcb.COPY_FROM_PARENT,                /* depth (same as root)*/
                   screen.root,                         /* parent window       */
                   0, 0,                                /* x, y                */
                   150, 150,                            /* width, height       */
                   10,                                  /* border_width        */
                   Xcb.WindowClass.INPUT_OUTPUT,        /* class               */
                   screen.root_visual);                 /* visual              */

    /* Map the window on the screen */
    window.map (connection);

    /* Make sure commands are sent before we pause so that the window gets shown */
    connection.flush ();

    Posix.pause ();

    return 0;
}
