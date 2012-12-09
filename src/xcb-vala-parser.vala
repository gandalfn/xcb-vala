/* xcb-vala-parser.vala
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
 *  Nicolas Bruguier <nicolas.bruguier@supersonicimagine.fr>
 */

static int
main (string[] inArgs)
{
    try
    {
        XCBVala.XmlParser parser = new XCBVala.XmlParser (inArgs[1]);
        XCBVala.XmlObject root = parser.parse ("xcb");

        GLib.FileUtils.set_contents (inArgs[2], root.to_string (""));

        string deps = "xcb-base\n";
        foreach (string dep in (root as XCBVala.Root).deps)
            deps += "%s\n".printf (dep);
        GLib.FileUtils.set_contents (inArgs[2].replace (".vapi", ".deps"), deps);
    }
    catch (GLib.Error e)
    {
        warning ("%s", e.message);
    }

    return 0;
}
