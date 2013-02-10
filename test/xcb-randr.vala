static int
main (string[] inArgs)
{
    // Connect to server
    Xcb.Connection connection = new Xcb.Connection ();

    // Check randr extension
    connection.prefetch_extension_data (ref Xcb.RandR.extension);
    unowned Xcb.QueryExtensionReply? extension_reply = connection.get_extension_data (ref Xcb.RandR.extension);

    if (!extension_reply.present)
    {
        print ("Randr extension is not supported\n");
        return 1;
    }
    print ("Randr extension event=%i error=%i\n", extension_reply.first_event, extension_reply.first_error);


    // Parse screen configuration
    foreach (unowned Xcb.Screen screen in connection.roots)
    {
        Xcb.GenericError? err = null;
        Xcb.RandR.Window root = (Xcb.RandR.Window)screen.root;
        Xcb.RandR.GetScreenResourcesReply reply = root.get_screen_resources (connection).reply (connection, out err);
        if (reply == null)
        {
            print ("Error on get screen ressources\n");
        }
        else
        {
            GLib.StringBuilder name = new GLib.StringBuilder ();
            name.append_len ((string)reply.names (), reply.names_length ());
            print ("Name: %s\n", name.str);
        }
        for (int cpt = 0; cpt < reply.crtcs_length (); ++cpt)
        {
            Xcb.RandR.GetCrtcInfoReply info_reply = reply.crtcs ()[cpt].get_info (connection, reply.config_timestamp).reply (connection, out err);
            if (info_reply != null)
            {
                print ("crtc: x=%i y=%i width=%i height=%i\n", info_reply.x, info_reply.y, info_reply.width, info_reply.height);
            }
            else
            {
                print ("Error on get crtc info %i\n", cpt);
            }
        }
        for (int cpt = 0; cpt < reply.outputs_length (); ++cpt)
        {
            Xcb.RandR.GetOutputInfoReply info_reply = reply.outputs ()[cpt].get_info (connection, reply.config_timestamp).reply (connection, out err);
            if (info_reply != null)
            {
                GLib.StringBuilder name = new GLib.StringBuilder ();
                name.append_len ((string)info_reply.name (), info_reply.name_length ());
                print ("output: %s width = %u mm height = %u mm\n", name.str, info_reply.mm_width, info_reply.mm_height);
            }
        }
        for (int cpt = 0; cpt < reply.modes_length (); ++cpt)
        {
            uint rate = (uint)((double)reply.modes()[cpt].dot_clock / ((double)reply.modes()[cpt].htotal * (double)reply.modes()[cpt].vtotal));
            print ("mode: %ux%u %u Hz\n", reply.modes()[cpt].width, reply.modes()[cpt].height, rate);
        }
    }

    return 0;
}
