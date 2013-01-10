/* void-request.vala
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

internal class XCB.Core.VoidRequest<Q> : XCB.Core.Request<Q>
{
    // methods
    public VoidRequest (Xcb.Extension? ext, uint8 opcode)
    {
        base (ext, opcode, true);
    }

    public void
    post (Connection connection, Q req)
    {
        send (connection, 0, req);
    }

    public void
    post_checked (Connection connection, Q req) throws Error
    {
        uint sequence = send (connection, Xcb.RequestFlags.CHECKED, req);

        Connection.Cookie cookie = connection.create_cookie (sequence, (bool)request.isvoid);
        if (cookie != null)
        {
            if (cookie.error != null)
            {
                error_from_xerror (cookie.error.error_code);
            }
        }
    }

    public async void
    post_checked_async (Connection connection, Q req) throws Error
    {
        uint sequence = send (connection, Xcb.RequestFlags.CHECKED, req);

        Connection.Cookie cookie = connection.create_cookie_async (sequence, (bool)request.isvoid, (Connection.Cookie.Callback)post_checked_async.callback);
        yield;

        if (cookie != null)
        {
            if (cookie.error != null)
            {
                error_from_xerror (cookie.error.error_code);
            }
        }
    }
}
