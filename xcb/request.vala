/* request.vala
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

internal abstract class XCB.Core.Request<Q> : GLib.Object
{
    // properties
    protected Xcb.ProtocolRequest? request;
    protected size_t               size;

    // methods
    protected Request (Xcb.Extension? ext, uint8 opcode, bool isvoid)
    {
        this.request = { 2, ext, opcode, (uint8)isvoid };
        this.size = sizeof (Q);
    }

    protected uint
    send (Connection connection, int flags, Q req)
    {
        Posix.iovector parts[4];

        parts[2].iov_base = (char*)req;
        parts[2].iov_len = size;
        parts[3].iov_base = null;
        parts[3].iov_len = -parts[2].iov_len & 3;

        return connection.connection.send_request (flags, ref parts[2], request);
    }
}
