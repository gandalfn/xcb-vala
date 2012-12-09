/* print names of modifiers present in mask */
static void
print_modifiers (uint32 mask)
{
    string[] MODIFIERS = {
            "Shift", "Lock", "Ctrl", "Alt",
            "Mod2", "Mod3", "Mod4", "Mod5",
            "Button1", "Button2", "Button3", "Button4", "Button5"
    };

    print ("Modifier mask: ");
    foreach (unowned string modifier in MODIFIERS)
    {
        if (mask == 0) break;
        if ((mask & 1) != 0)
        {
            print (modifier + " ");
        }
        mask >>= 1;
    }
    print ("\n");
}

static int
main (string[] inArgs)
{
    /* Get the first screen */
    Xcb.Connection connection = new Xcb.Connection ();
    unowned Xcb.Screen screen = connection.roots[0];

    /* Create the window */
    Xcb.Window window = Xcb.Window (connection);

    uint32 mask = Xcb.Cw.BACK_PIXEL | Xcb.Cw.EVENT_MASK;
    uint32 values[2] = { screen.white_pixel,
                         Xcb.EventMask.EXPOSURE       | Xcb.EventMask.BUTTON_PRESS   |
                         Xcb.EventMask.BUTTON_RELEASE | Xcb.EventMask.POINTER_MOTION |
                         Xcb.EventMask.ENTER_WINDOW   | Xcb.EventMask.LEAVE_WINDOW   |
                         Xcb.EventMask.KEY_PRESS      | Xcb.EventMask.KEY_RELEASE };

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

    Xcb.GenericEvent? event;
    while ((event = connection.wait_for_event ()) != null)
    {
        switch (event.response_type & ~0x80)
        {
            case Xcb.EventType.EXPOSE:
                unowned Xcb.ExposeEvent? expose = (Xcb.ExposeEvent?)event;

                print ("Window %ld exposed. Region to be redrawn at location (%d,%d), with dimension (%d,%d)\n",
                        expose.window, expose.x, expose.y, expose.width, expose.height);
                break;

            case Xcb.EventType.BUTTON_PRESS:
                unowned Xcb.ButtonPressEvent? bp = (Xcb.ButtonPressEvent?)event;
                print_modifiers (bp.state);

                switch (bp.detail)
                {
                    case 4:
                        print ("Wheel Button up in window %ld, at coordinates (%d,%d)\n",
                               bp.event, bp.event_x, bp.event_y);
                        break;
                    case 5:
                        print ("Wheel Button down in window %ld, at coordinates (%d,%d)\n",
                               bp.event, bp.event_x, bp.event_y);
                        break;
                    default:
                        print ("Button %d pressed in window %ld, at coordinates (%d,%d)\n",
                               bp.detail, bp.event, bp.event_x, bp.event_y);
                        break;
                }
                break;

            case Xcb.EventType.BUTTON_RELEASE:
                unowned Xcb.ButtonReleaseEvent? br = (Xcb.ButtonReleaseEvent?)event;
                print_modifiers (br.state);

                print ("Button %d released in window %ld, at coordinates (%d,%d)\n",
                       br.detail, br.event, br.event_x, br.event_y);
                break;

            case Xcb.EventType.MOTION_NOTIFY:
                unowned Xcb.MotionNotifyEvent? motion = (Xcb.MotionNotifyEvent?)event;

                print ("Mouse moved in window %ld, at coordinates (%d,%d)\n",
                       motion.event, motion.event_x, motion.event_y);
                break;

            case Xcb.EventType.ENTER_NOTIFY:
                unowned Xcb.EnterNotifyEvent? enter = (Xcb.EnterNotifyEvent?)event;

                print ("Mouse entered window %ld, at coordinates (%d,%d)\n",
                       enter.event, enter.event_x, enter.event_y);
                break;

            case Xcb.EventType.LEAVE_NOTIFY:
                unowned Xcb.LeaveNotifyEvent? leave = (Xcb.LeaveNotifyEvent?)event;

                print ("Mouse left window %ld, at coordinates (%d,%d)\n",
                       leave.event, leave.event_x, leave.event_y);
                break;

            case Xcb.EventType.KEY_PRESS:
                unowned Xcb.KeyPressEvent? kp = (Xcb.KeyPressEvent?)event;
                print_modifiers (kp.state);

                print ("Key pressed in window %ld\n",
                       kp.event);
                break;

            case Xcb.EventType.KEY_RELEASE:
                unowned Xcb.KeyReleaseEvent? kr = (Xcb.KeyReleaseEvent?)event;
                print_modifiers (kr.state);

                print ("Key released in window %ld\n",
                       kr.event);
                break;

            default:
                /* Unknown event type, ignore it */
                print ("Unknown event: %d\n",
                       event.response_type);
                break;
        }
    }

    return 0;
}
