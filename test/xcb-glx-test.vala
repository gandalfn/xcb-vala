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

static uint32
glx_get_property (uint32* prop_list, uint prop_count, uint32 prop_name)
{
    uint32 i = 0;
    while (i < prop_count * 2)
    {
        if (prop_list[i] == prop_name) return prop_list[i + 1];
        i += 2;
    }

    print ("ERROR: no matches found for property %u!\n", prop_name);
    return -1;
}

static uint32
glx_choose_fb_configs (Xcb.Connection connection, int screen_num, uint32[] attrib_list, out Xcb.Visualid outVisualID)
{
    outVisualID = 0;

    Xcb.Glx.GetFbconfigsCookie cookie = ((Xcb.Glx.Connection)connection).get_fb_configs (screen_num);
    Xcb.GenericError error;

    // getting fbconfig list
    Xcb.Glx.GetFbconfigsReply reply = cookie.reply ((Xcb.Glx.Connection)connection, out error);
    if (error != null)
    {
        print ("ERROR: can't get fb configs\n");
        Posix.exit (-1);
    }

    unowned uint32[] prop_list = reply.property_list;
    uint32* fbconfig_line   = (uint32*)prop_list;
    uint32  fbconfig_linesz = reply.num_properties * 2; // *2 since each line contains also values

#if 0
    for (int i = 0 ; i < reply.num_FB_configs; i++)
    {
        for (int j = 0; j < reply.num_properties * 2; j += 2)
            print ("%u %u\n", fbconfig_line[j], fbconfig_line[j + 1]);
        print("-----------------------------------------------------------------------\n");
        fbconfig_line += fbconfig_linesz; // next fbconfig line;
    }
#endif
    fbconfig_line   = (uint32*)prop_list;

    for (int i = 0; i < reply.num_FB_configs; ++i)
    {
        bool good_fbconfig = true;

        // for each attrib
        for (uint j = 0; j < attrib_list.length; j += 2)
        {
            // if property found != property given
            if (glx_get_property (fbconfig_line, reply.num_properties, attrib_list[j]) != attrib_list[j + 1])
            {
                good_fbconfig = false; // invalidate this fbconfig entry, sine one of the attribs doesn't match
                break;
            }
        }

        // if all attribs matched, return with fid
        if (good_fbconfig)
        {
            outVisualID = glx_get_property (fbconfig_line, reply.num_properties, GLX.GLX_VISUAL_ID);
            return glx_get_property (fbconfig_line, reply.num_properties, GLX.GLX_FBCONFIG_ID);
        }

        fbconfig_line += fbconfig_linesz; // next fbconfig line;
    }

    return 0;
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
                            GLX.GLX_DRAWABLE_TYPE, GLX.GLX_WINDOW_BIT | GLX.GLX_PIXMAP_BIT | GLX.GLX_PBUFFER_BIT };

    /* get fb configs */
    Xcb.Visualid glxvisual;
    Xcb.Glx.Fbconfig fbconfig = glx_choose_fb_configs (connection, screenNum,
                                                       glxattribs, out glxvisual);
    print ("choosing fbconfig id 0x%X with visual id 0x%X\n", fbconfig, glxvisual );

    /* creating glx context */
    Xcb.Glx.Context context = Xcb.Glx.Context ((Xcb.Glx.Connection)connection);
    Xcb.VoidCookie cookie_context = context.create_new_checked ((Xcb.Glx.Connection)connection, fbconfig, screenNum, GLX.GLX_RGBA_TYPE, 0, true);
    test_cookie (cookie_context, connection, "can't create glx context");

    /* create colormap */
    Xcb.Colormap colormap = Xcb.Colormap (connection);
    colormap.create (connection, Xcb.ColormapAlloc.NONE, screen.root, glxvisual);

    /* creating an Window, using our new colormap */
    uint32[] values = { screen.black_pixel, 0,
                        Xcb.EventMask.KEY_RELEASE | Xcb.EventMask.BUTTON_PRESS |
                        Xcb.EventMask.EXPOSURE    | Xcb.EventMask.POINTER_MOTION,
                        colormap };
    uint32 mask = Xcb.Cw.BACK_PIXEL | Xcb.Cw.OVERRIDE_REDIRECT |
                  Xcb.Cw.EVENT_MASK | Xcb.Cw.COLORMAP;

    Xcb.Window window = Xcb.Window (connection);
    Xcb.VoidCookie window_cookie = window.create_checked (connection,
                                                          screen.root_depth,
                                                          screen.root,
                                                          0, 0,
                                                          640, 480,
                                                          0,
                                                          Xcb.WindowClass.INPUT_OUTPUT,
                                                          glxvisual,
                                                          mask, values);
    test_cookie (window_cookie, connection, "can't create window");
    window.map (connection);

    /* making our glx context current */
    Xcb.GenericError error;
    Xcb.Glx.MakeContextCurrentCookie cookie_make_current = ((Xcb.Glx.Drawable)window).make_context_current((Xcb.Glx.Connection)connection, 0, (Xcb.Glx.Drawable)window, context);
    Xcb.Glx.MakeContextCurrentReply reply_make_current = cookie_make_current.reply ((Xcb.Glx.Connection)connection, out error);
    if (error != null)
    {
        print ("ERROR: can't make current context\n");
        Posix.exit (-1);
    }
    Xcb.Glx.Context_tag tag = reply_make_current.context_tag;

    connection.flush ();

    // setting up opengl
    GL.glShadeModel(GL.GL_SMOOTH );
    GL.glHint      (GL.GL_PERSPECTIVE_CORRECTION_HINT, GL.GL_NICEST);
    GL.glClearColor(1.0f, 1.0f, 0.0f, 0.0f);  // Yellow Background
    GL.glClearDepth(1.0f );                   //enables clearing of deapth buffer
    GL.glEnable    (GL.GL_DEPTH_TEST);        //enables depth testing
    GL.glDepthFunc (GL.GL_LEQUAL);            //type of depth test
    GL.glEnable    (GL.GL_TEXTURE_2D);        //enable texture mapping
    GL.glEnable    (GL.GL_BLEND);
    GL.glBlendFunc (GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA );
    GL.glViewport  (0, 0, 640, 480);
    GL.glFinish    ();

    /* event loop */
    Xcb.GenericEvent event;
    while ((event = connection.wait_for_event ()) != null)
    {
        switch (event.response_type & ~0x80)
        {
            case Xcb.EventType.EXPOSE:
                // redrawing our scene
                GL.glClear (GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

                // setting up camera
                GL.glMatrixMode (GL.GL_PROJECTION);
                GL.glLoadIdentity ();
                // adding some perspective
                GL.glFrustum (-1.0f , 1.0f , -1.0f, 1.0f, 1.0f, 1000.0f);
                GL.glMatrixMode (GL.GL_MODELVIEW);
                GL.glLoadIdentity ();
                GL.glTranslatef (0.0f, 0.0f, -2.0f); // moving camera back, so i can see stuff i draw

                // drawing a triangle to test
                GL.glBegin (GL.GL_TRIANGLES);
                GL.glColor3f (1.0f, 0.0f, 0.5f);
                GL.glVertex3f (1.0f, 1.0f, 0.0f);
                GL.glVertex3f (1.0f, 0.0f, 0.0f);
                GL.glVertex3f( 0.0f, 1.0f, 0.0f);
                GL.glEnd ();
                GL.glFinish ();

                ((Xcb.Glx.Drawable)window).swap_buffers ((Xcb.Glx.Connection)connection, tag);

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

    context.destroy ((Xcb.Glx.Connection)connection);
    window.destroy (connection);

    return 0;
}
