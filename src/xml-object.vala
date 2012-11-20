/* xml-object.vala
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

namespace XCBVala
{
    public interface XmlObject : GLib.Object
    {
        // types
        private class TagFactory
        {
            public string m_Tag;
            public GLib.Type m_Type;

            public TagFactory (string inTag, GLib.Type inType)
            {
                m_Tag = inTag;
                m_Type = inType;
            }

            public int
            compare (TagFactory inOther)
            {
                return GLib.strcmp (m_Tag, inOther.m_Tag);
            }

            public int
            compare_with_tag (string inTag)
            {
                return GLib.strcmp (m_Tag, inTag);
            }
        }

        public class Iterator
        {
            // properties
            internal Set.Iterator<XmlObject> m_Iter;

            // methods
            /**
             * description
             */
            internal Iterator (XmlObject inObject)
            {
                m_Iter = inObject.childs.iterator ();
            }

            public bool
            next ()
            {
                return m_Iter.next ();
            }

            public new unowned XmlObject?
            @get ()
            {
                return m_Iter.get ();
            }
        }

        // accessors
        protected abstract string tag_name { get; }
        protected abstract unowned XmlObject? parent { get; set; }
        protected abstract unowned Set<XmlObject>? childs { get; }

        public abstract string name { get; set; }
        public abstract int pos { get; set; }
        public abstract string characters { get; set; }
        public string characters_unformatted {
            owned get {
                var text = characters;

                if (text.has_prefix (XmlParser.CDATA_PREFIX) && text.has_suffix (XmlParser.CDATA_SUFFIX))
                {
                    text = text.substring (XmlParser.CDATA_PREFIX.length, text.length - XmlParser.CDATA_PREFIX.length - XmlParser.CDATA_SUFFIX.length);
                }

                return text;
            }
        }

        public unowned XmlObject? root {
            get {
                unowned XmlObject? p = parent;

                if (p != null)
                {
                    while (p.parent != null)
                    {
                        p = p.parent;
                    }
                }

                return p;
            }
        }

        public GLib.List<unowned XmlObject> childs_unsorted {
            owned get {
                GLib.List<unowned XmlObject> ret = new GLib.List<unowned XmlObject> ();
                foreach (unowned XmlObject child in this)
                {
                    ret.insert_sorted (child, compare_with_pos);
                }
                return ret;
            }
        }
        // static properties
        private static Set<TagFactory> s_Factory;

        // static methods
        /**
         * Register an object function creation for a tag name
         *
         * @param inName tag name
         * @param inType type of a new XMLObject
         */
        public static void
        register_object (string inName, GLib.Type inType)
        {
            if (s_Factory == null)
            {
                s_Factory = new Set<TagFactory> (TagFactory.compare);
            }

            s_Factory.insert (new TagFactory (inName, inType));
        }

        /**
         * Unregister an object function creation for a tag name
         *
         * @param inName tag name
         */
        public static void
        unregister_object (string inName)
        {
            unowned TagFactory? factory = s_Factory.search<string> (inName, TagFactory.compare_with_tag);
            if (factory != null)
            {
                s_Factory.remove (factory);
            }
        }

        /**
         * Format an attribute name: all leading upper case characters
         * are replaced by lower case characters preceed by underscore.
         *
         * @param inName attribute name
         *
         * @return formatted attribute name
         */
        protected static string
        format_attribute_name (string inName)
        {
            GLib.StringBuilder ret = new GLib.StringBuilder("");
            bool previous_is_upper = true;

            unowned char[] s = (char[])inName;
            for (int cpt = 0; s[cpt] != 0; ++cpt)
            {
                char c = s [cpt];
                if (c.isupper() || c.isdigit ())
                {
                    if (!previous_is_upper) ret.append_unichar ('_');
                    ret.append_unichar (c.tolower());
                    previous_is_upper = true;
                }
                else
                {
                    ret.append_unichar (c);
                    previous_is_upper = false;
                }
            }

            return ret.str == "type" ? "attrtype" : ret.str;
        }

        internal static XmlObject?
        create (string inName, Set<Parser.Attribute>? inParams)
        {
            XmlObject? item = null;

            if (s_Factory != null)
            {
                unowned TagFactory? factory = s_Factory.search<string> (inName, TagFactory.compare_with_tag);
                if (factory != null)
                {
                    item = (XmlObject)GLib.Object.new (factory.m_Type);
                    if (item != null)
                    {
                        foreach (unowned Parser.Attribute attr in inParams)
                        {
                            item.set_attribute (attr.m_Name, attr.m_Value);
                        }
                    }
                }
            }

            return item;
        }

        // methods
        private int
        compare_with_pos (XmlObject inObject)
        {
            return pos - inObject.pos;
        }

        /**
         * Parse xml for this object
         *
         * @param inParser XML parser
         *
         * @throw ParserError when somethings goes wrong
         */
        public void
        parse (Parser inParser) throws ParseError
        {
            string? wait = null;
            foreach (Parser.Token token in inParser)
            {
                switch (token)
                {
                    case Parser.Token.START_ELEMENT:
                        {
                            if (wait == null)
                            {
                                Set<Parser.Attribute> params = inParser.attributes;
                                XmlObject item = create (inParser.element, params);
                                if (item != null)
                                {
                                    append_child (item);
                                    item.parse (inParser);
                                }
                                else
                                    wait = inParser.element;
                            }
                        }
                        break;
                    case Parser.Token.END_ELEMENT:
                        if (inParser.element == tag_name)
                        {
                            on_end ();
                            return;
                        }
                        else if (wait != null && inParser.element == wait)
                        {
                            wait = null;
                        }
                        break;
                    case Parser.Token.CHARACTERS:
                        if (wait == null)
                        {
                            characters = inParser.characters;
                        }
                        break;
                    case Parser.Token.EOF:
                        return;
                }
            }
        }

        /**
         * Called when a object child has been added
         *
         * @param inChild object child
         */
        public abstract void
        on_child_added (XmlObject inChild);

        public int
        compare (XmlObject inOther)
        {
            return GLib.strcmp (name, inOther.name);
        }

        public int
        compare_with_name (string inName)
        {
            return GLib.strcmp (name, inName);
        }

        /**
         * Called when object tag end has be found
         */
        public abstract void
        on_end ();

        /**
         * Returns a Iterator that can be used for simple iteration over a child objects.
         *
         * @return Iterator
         */
        public Iterator
        iterator ()
        {
            return new Iterator (this);
        }

        /**
         * Add a child item to Object
         *
         * @param inObject child object to add
         */
        public void
        append_child (XmlObject inChild)
        {
            if (!(inChild in childs))
            {
                childs.insert (inChild);
                inChild.pos = childs.length - 1;
                inChild.parent = this;
                on_child_added (inChild);
            }
        }

        /**
         * Remove a child item to Object
         *
         * @param inObject child object to remove
         */
        public void
        remove_child (XmlObject inChild)
        {
            if (inChild in childs)
            {
                int pos = inChild.pos;
                foreach (unowned XmlObject child in this)
                {
                    if (child.pos > pos);
                    {
                        child.pos--;
                    }
                }
                inChild.parent = null;
                childs.remove (inChild);
            }
        }

        /**
         * Return the corresponding child item
         *
         * @param inNodeId child node name
         *
         * @return child item
         */
        public unowned XmlObject?
        get (string inNodeName)
        {
            return childs != null ? childs.search<string> (inNodeName, XmlObject.compare_with_name) : null;
        }

        /**
         * Find an child item in this and its childrens
         *
         * @param inNodeId child node id
         *
         * @return child item
         */
        public unowned XmlObject?
        find (string inNodeId)
        {
            unowned XmlObject? ret = get (inNodeId);

            if (ret == null && childs != null)
            {
                foreach (unowned XmlObject? item in childs)
                {
                    ret = item.find (inNodeId);
                    if (ret != null) return ret;
                }
            }

            return ret;
        }

        /**
         * Find child items which correspond to inType
         *
         * @return list of object of inType
         */
        public GLib.List<unowned T>
        find_childs_of_type<T> ()
        {
            GLib.List<unowned T> ret = new GLib.List<unowned T> ();

            if (childs != null)
            {
                foreach (unowned XmlObject? item in childs)
                {
                    if (item.get_type ().is_a (typeof (T)))
                    {
                        ret.append (item);
                    }

                    ret.concat (item.find_childs_of_type<T> ());
                }
            }

            return ret;
        }

        /**
         * Get value in string format of element inName attribute.
         *
         * @param inName attribute name
         *
         * @return attribute value in string format
         */
        public string?
        get_attribute (string inName)
        {
            // Search property in object class
            string ret = null;
            string name = format_attribute_name (inName);
            unowned GLib.ParamSpec param = get_class ().find_property (name);

            // We found property which correspond to attribute name convert it to
            // string format
            if (param != null)
            {
                GLib.Value val = GLib.Value (param.value_type);
                GLib.Value o = GLib.Value (typeof (string));
                get_property (name, ref val);
                val.transform (ref o);
                ret = (string)o;
            }

            return ret;
        }

        /**
         * Set value of element inName attribute.
         *
         * @param inName attribute name
         * @param inValue new attribute value
         */
        public void
        set_attribute (string inName, string inValue)
        {
            // Search property in object class
            string name = format_attribute_name (inName);
            unowned GLib.ParamSpec param = get_class ().find_property (name);

            // We found property which correspond to attribute name convert value
            // to property type and set
            if (param != null)
            {
                set_property (name, XCBVala.Value.from_string (param.value_type, inValue));
            }
        }

        public abstract string
        to_string (string inPrefix);
    }
}
