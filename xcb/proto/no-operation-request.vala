/* no-operation-request.vala
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

internal struct XCB.NoOperationArgs
{
    uint8  major_opcode;
    uint8  pad0;
    uint16 length;

    public NoOperationArgs ()
    {
        major_opcode = 0;
        pad0 = 0;
        length = 0;
    }
}

internal class XCB.NoOperationRequest : Core.VoidRequest<NoOperationArgs?>
{
    public NoOperationRequest ()
    {
        base (null, 127);
    }

    public new void
    post (Core.Connection connection)
    {
        base.post (connection, NoOperationArgs ());
    }

    public new void
    post_checked (Core.Connection connection) throws Error
    {
        base.post_checked (connection, NoOperationArgs ());
    }

    public new async void
    post_checked_async (Core.Connection connection) throws Error
    {
        yield base.post_checked_async (connection, NoOperationArgs ());
    }
}
