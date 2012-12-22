static void
glx_check_version (Xcb.Connection connection, uint major, uint minor )
{
    Xcb.Glx.QueryVersionCookie cookie = ((Xcb.Glx.Connection)connection).query_version (major, minor);
    Xcb.GenericError error;

    Xcb.Glx.QueryVersionReply reply = cookie.reply ((Xcb.Glx.Connection)connection, out error);
    if (error != null)
    {
        print ("ERROR: can't get glx version\n");
        Posix.exit (-1);
    }
    if (reply.major_version < major || (reply.major_version == major && reply.minor_version < minor))
    {
        print ("ERROR: need at least %u.%u glx extention, found %u.%u\n",
               major, minor, reply.major_version, reply.minor_version );
        Posix.exit (-1);
    }
    print ("GLX: version %u.%u\n", reply.major_version, reply.minor_version);
}

static void
glx_choose_fb_configs (Xcb.Connection connection, int screen_num, uint32[] attrib_list)
{
    Xcb.Glx.GetFbconfigsCookie cookie = ((Xcb.Glx.Connection)connection).get_fb_configs (screen_num);
    Xcb.GenericError error;

    // getting fbconfig list
    Xcb.Glx.GetFbconfigsReply reply = cookie.reply ((Xcb.Glx.Connection)connection, out error);
    if (error != null)
    {
        print ("ERROR: can't get fb configs\n");
        Posix.exit (-1);
    }

    uint32[] prop_list = reply.property_list ();

    for (int i = 0 ; i < reply.property_list_length (); i++)
    {
        if (i > 0 && (i % 80) == 0) print ("\n");  //print a newline after each fbconfig line
        print ("%u\t", prop_list[i]);
    }
    print("\n-----------------------------------------------------------------------\n");
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

    /* check glx version at least 1.3 */
    glx_check_version (connection, 1, 3);

    uint32[] glxattribs = { GLX.GLX_DOUBLEBUFFER, 1,
                            GLX.GLX_RED_SIZE, 8,
                            GLX.GLX_GREEN_SIZE, 8,
                            GLX.GLX_BLUE_SIZE, 8,
                            GLX.GLX_ALPHA_SIZE, 8,
                            GLX.GLX_RENDER_TYPE, GLX.GLX_RGBA_BIT,
                            GLX.GLX_DRAWABLE_TYPE, GLX.GLX_WINDOW_BIT };

    /* get fb configs */
    glx_choose_fb_configs (connection, screenNum, glxattribs);

    return 0;
}
