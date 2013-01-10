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

public class XCB.Connection : XCB.Core.Connection
{
    // properties
    private static NoOperationRequest no_operation_request;

    // static methods
    static construct
    {
        no_operation_request = new NoOperationRequest ();
    }

    // methods
    public Connection (string? display = null) throws ConnectionError
    {
        base (display);
    }

    public void
    no_operation ()
    {
        no_operation_request.post (this);
    }

    public void
    no_operation_checked () throws Error
    {
        no_operation_request.post_checked (this);
    }

    public async void
    no_operation_checked_async () throws Error
    {
        yield no_operation_request.post_checked_async (this);
    }
}
