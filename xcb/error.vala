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

public errordomain XCB.Error
{
    BAD_REQUEST,
    BAD_VALUE,
    BAD_WINDOW,
    BAD_PIXMAP,
    BAD_ATOM,
    BAD_CURSOR,
    BAD_FONT,
    BAD_MATCH,
    BAD_DRAWABLE,
    BAD_ACCESS,
    BAD_ALLOC,
    BAD_COLOR,
    BAD_GC,
    BAD_IDCHOICE,
    BAD_NAME,
    BAD_LENGTH,
    BAD_IMPLEMENTATION;
}

namespace XCB
{
    internal static void
    error_from_xerror (int inCode) throws Error
    {
        switch (inCode)
        {
            case 1:
                throw new Error.BAD_REQUEST ("invalid request code or no such operation");
            case 2:
                throw new Error.BAD_VALUE ("integer parameter out of range for operation");
            case 3:
                throw new Error.BAD_WINDOW ("invalid Window parameter");
            case 4:
                throw new Error.BAD_PIXMAP ("invalid Pixmap parameter");
            case 5:
                throw new Error.BAD_ATOM ("invalid Atom parameter");
            case 6:
                throw new Error.BAD_CURSOR ("invalid Cursor parameter");
            case 7:
                throw new Error.BAD_FONT ("invalid Font parameter");
            case 8:
                throw new Error.BAD_MATCH ("invalid parameter attributes");
            case 9:
                throw new Error.BAD_DRAWABLE ("invalid Pixmap or Window parameter");
            case 10:
                throw new Error.BAD_ACCESS ("attempt to access private resource denied");
            case 11:
                throw new Error.BAD_ALLOC ("insufficient resources for operation");
            case 12:
                throw new Error.BAD_COLOR ("invalid Colormap parameter");
            case 13:
                throw new Error.BAD_GC ("invalid GC parameter");
            case 14:
                throw new Error.BAD_IDCHOICE ("invalid resource ID chosen for this connection");
            case 15:
                throw new Error.BAD_NAME ("named color or font does not exist");
            case 16:
                throw new Error.BAD_LENGTH ("poly request too large or internal Xlib length error");
            case 17:
                throw new Error.BAD_IMPLEMENTATION ("server does not implement operation");
        }
        return;
    }
}
