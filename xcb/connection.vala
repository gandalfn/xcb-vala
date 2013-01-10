/* connection.vala
 *
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

public errordomain XCB.ConnectionError
{
    INIT,
    WATCH
}

public class XCB.Core.Connection : GLib.Object
{
    // types
    internal class Cookie : GLib.Object
    {
        // type
        internal delegate void Callback ();

        // properties
        private uint              _sequence;
        private Xcb.GenericReply? _reply;
        private Xcb.GenericError? _error;
        private Callback          _func;
        private bool              _isvoid;

        // accessors
        public int sequence {
            get {
                return (int)_sequence;
            }
        }

        public Xcb.GenericReply? reply {
            get {
                return _reply;
            }
        }

        public Xcb.GenericError? error {
            get {
                return _error;
            }
        }

        public Cookie (uint sequence, bool isvoid)
        {
            _sequence = sequence;
            _func = null;
            _reply = null;
            _error = null;
            _isvoid = isvoid;
        }

        public Cookie.async (uint sequence, bool isvoid, owned Callback func)
        {
            _sequence = sequence;
            _func = (owned)func;
            _reply = null;
            _error = null;
            _isvoid = isvoid;
        }

        public inline bool
        check (Connection connection)
        {
            bool ret = false;

            if (_isvoid)
            {
                _error = connection.connection.request_check ({ _sequence });
                ret = true;
            }
            else
            {
                ret = connection.connection.poll_for_reply (_sequence, out _reply, out _error) != 0;
            }

            if (ret && _func != null) _func ();

            return ret;
        }
    }

    // properties
    private Xcb.Connection               _connection = null;
    private GLib.MainLoop                _loop;
    private GLib.IOChannel               _channel;
    private GLib.HashTable<int?, Cookie> _cookies;
    private uint                         _cookie_id;

    // accessors
    internal Xcb.Connection? connection {
        get {
            return _connection;
        }
    }

    // signals
    public signal void event ();

    // methods
    internal Connection (string? display = null) throws ConnectionError
    {
        int screen;
        _connection = new Xcb.Connection (display, out screen);

        if (_connection == null)
        {
            throw new ConnectionError.INIT ("Error on connect to server");
        }
        open_fd ();

        _cookies = new GLib.HashTable<int?, Cookie> (GLib.int_hash, GLib.int_equal);
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
                    event ();
                }
            }
        }
        else
        {
            _loop.quit ();
        }

        return ret;
    }

    private bool
    on_check_cookies ()
    {
        if (_cookie_id != 0)
        {
            foreach (unowned Cookie cookie in _cookies.get_values ())
            {
                if (cookie.check (this))
                {
                    _cookies.remove (cookie.sequence);
                }
            }

            if (_cookies.size () == 0) _cookie_id = 0;
        }

        return _cookie_id != 0;
    }

    internal Cookie
    create_cookie (uint sequence, bool isvoid)
    {
        return new Cookie (sequence, isvoid);
    }

    internal Cookie
    create_cookie_async (uint sequence, bool isvoid, owned Cookie.Callback func)
    {
        Cookie cookie = new Cookie.async (sequence, isvoid, (owned)func);

        _cookies.insert ((int)sequence, cookie);

        if (_cookie_id == 0)
        {
            _cookie_id = GLib.Idle.add (on_check_cookies);
        }

        return cookie;
    }

    public void
    flush ()
    {
        connection.flush ();
    }

    public void
    process_events ()
    {
        _loop.run ();
    }
}
