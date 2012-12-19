/* xcb-vapigen.vala
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

// static methods
static void
init ()
{
    XCBVala.XmlObject.register_object ("import",    typeof (XCBVala.Import));
    XCBVala.XmlObject.register_object ("xcb",       typeof (XCBVala.Root));
    XCBVala.XmlObject.register_object ("struct",    typeof (XCBVala.Class));
    XCBVala.XmlObject.register_object ("field",     typeof (XCBVala.Field));
    XCBVala.XmlObject.register_object ("typedef",   typeof (XCBVala.Typedef));
    XCBVala.XmlObject.register_object ("xidtype",   typeof (XCBVala.XIDType));
    XCBVala.XmlObject.register_object ("xidunion",  typeof (XCBVala.XIDUnion));
    XCBVala.XmlObject.register_object ("enum",      typeof (XCBVala.Enum));
    XCBVala.XmlObject.register_object ("item",      typeof (XCBVala.Item));
    XCBVala.XmlObject.register_object ("event",     typeof (XCBVala.Event));
    XCBVala.XmlObject.register_object ("eventcopy", typeof (XCBVala.EventCopy));
    XCBVala.XmlObject.register_object ("error",     typeof (XCBVala.Error));
    XCBVala.XmlObject.register_object ("errorcopy", typeof (XCBVala.ErrorCopy));
    XCBVala.XmlObject.register_object ("union",     typeof (XCBVala.Union));
    XCBVala.XmlObject.register_object ("list",      typeof (XCBVala.List));
    XCBVala.XmlObject.register_object ("value",     typeof (XCBVala.ValueItem));
    XCBVala.XmlObject.register_object ("valueparam",typeof (XCBVala.ValueParam));
    XCBVala.XmlObject.register_object ("fieldref",  typeof (XCBVala.FieldRef));
    XCBVala.XmlObject.register_object ("request",   typeof (XCBVala.Request));
    XCBVala.XmlObject.register_object ("reply",     typeof (XCBVala.Reply));
}

static int
main (string[] inArgs)
{
    init ();

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
