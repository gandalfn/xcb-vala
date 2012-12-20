/*
 * Copyright (C) 2012  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <gandalfn@club-internet.fr>
 */

public errordomain Xcb.Vala.ConnectionError
{
    INIT,
    WATCH
}

public class Xcb.Vala.Connection : GLib.Object
{
    // properties
    private Xcb.Connection _connection = null;
    private GLib.MainLoop  _loop;
    private GLib.IOChannel _channel;

    // accessors
    public Xcb.Connection? connection {
        get {
            return _connection;
        }
    }

    // signals
    public signal void event (Xcb.GenericEvent? evt);

    // methods
    public Connection (string? display = null) throws ConnectionError
    {
        int screen;
        _connection = new Xcb.Connection (display, out screen);

        if (_connection == null)
        {
            throw new ConnectionError.INIT ("Error on connect to server");
        }
        open_fd ();
    }

    private void
    open_fd () throws ConnectionError
    {
        _loop = new GLib.MainLoop ();

        try
        {
            _channel = new GLib.IOChannel.unix_new (_connection.file_descriptor);
            _channel.set_encoding (null);
            _channel.set_buffered (false);
            _channel.set_close_on_unref (false);
            _channel.add_watch (GLib.IOCondition.IN  | GLib.IOCondition.PRI |
                                GLib.IOCondition.ERR | GLib.IOCondition.HUP |
                                GLib.IOCondition.NVAL, on_data);
        }
        catch (GLib.Error err)
        {
            throw new ConnectionError.WATCH ("Error on watch connection: %s", err.message);
        }
    }

    private bool
    on_data (GLib.IOChannel channel, GLib.IOCondition condition)
    {
        bool ret = false;

        if (condition == GLib.IOCondition.IN || condition == GLib.IOCondition.PRI)
        {
            Xcb.GenericEvent? evt;
            while ((evt = _connection.poll_for_event ()) != null)
            {
                if ((evt.response_type & ~0x80) != 0)
                {
                    event (evt);
                }
            }
        }
        else
        {
            _loop.quit ();
        }

        return ret;
    }

    public void
    process_events ()
    {
        _loop.run ();
    }
}
